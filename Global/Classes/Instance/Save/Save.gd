### ----------------------------------------------------
# Manages SQLite
# 	SQLSave is a main save file that stores save data which consists of:
# 	- PlayerData (GAMEDATA_TABLE -> PLAYER_DATA)
# 	- EditedMaps (GAMEDATA_TABLE -> MapName)
# To setup a save use create_new_save() and initialize()
# To load use Load()
# To save use Save()
### ----------------------------------------------------

extends RefCounted
class_name Save

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

# Names of all tables that need to be created
enum TABLE_NAMES {GAMEDATA_TABLE, MAPDATA_TABLE}
# Keys in GameData table (compressed dicts are values)
enum GAMEDATA_KEYS {PLAYER_DATA}

# Content of all tables
const TABLE_CONTENT = { 
	"Key":{"primary_key":true,"data_type":"text", "not_null": true},
	"CData":{"data_type":"text", "not_null": true},
	"DCSize":{"data_type":"int", "not_null": true},
}

const TEMP_MARKER = "_TEMP" # Added to ending of all temp files
 
# Temp save is used as proxy file for save
# since save is managed via sql it needs to edit a file
# TEMP file is temporary file that is currently being used and edited
# DEST file is destination file that holds final save
var SQL_DB_CURR:SQLiteWrapper # Currently used save file
var SQL_DB_TEMP:SQLiteWrapper # Temp save file
var SQL_DB_DEST:SQLiteWrapper # The main save file 

var FILE_NAME:String	    # Name of the database file
var FILE_DIR:String         # Database file dir
var beVerbose:bool

### ----------------------------------------------------
# Functions
### ----------------------------------------------------
 
func _init(fileDir:String, fileName:String, verbose = false) -> void:
	beVerbose = verbose
	FILE_DIR = fileDir
	FILE_NAME = fileName
	
	SQL_DB_TEMP = SQLiteWrapper.new(
		FILE_DIR + FILE_NAME + TEMP_MARKER + ".db",
		SQLite.QUIET)
	
	SQL_DB_DEST = SQLiteWrapper.new(
		FILE_DIR + FILE_NAME + ".db",
		SQLite.QUIET)

# If save already exists, create a new one and put old one in the trash
func create_new_save() -> bool:
	if(SQL_DB_DEST.has_file()):
		if(SQL_DB_DEST.delete_file() != OK):
			Logger.log_err(["Unable to delete SQLSave save file: ", SQL_DB_DEST.path])
			return false
	
	var result := SQL_DB_DEST.create_new_file()
	if(result != OK):
		Logger.log_err(["Unable to create empty SQLSave save file: ", SQL_DB_DEST.path, ", err: ", result])
		return false
	
	var isOK := true
	for TID in TABLE_NAMES.values():
		var tableName:String = TABLE_NAMES.keys()[TID]
		isOK = isOK and SQL_DB_DEST.add_table(tableName, TABLE_CONTENT)
	
	_init_GAMEDATA_TABLE()
	
	if(not isOK): Logger.log_err(["Failed to create SQLSave save file tables: ", SQL_DB_DEST.path])
	elif(isOK):   Logger.log_msg(["Created SQLSave save file at: ", SQL_DB_DEST.path])
	return isOK

func _init_GAMEDATA_TABLE() -> void:
	var TemplatePlayer := PlayerEntity.new()
	SQL_DB_DEST.sql_save_compressed(
		TemplatePlayer.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	TemplatePlayer.free()

# Should be called after init before trying to acess data from save
func Load() -> bool:
	if(not SQL_DB_DEST.has_file()):
		Logger.log_err(["Tried to init non existing save: ", SQL_DB_DEST.path])
		return false
	if(FileUtils.copy_file(SQL_DB_DEST.path, SQL_DB_TEMP.path) != OK):
		Logger.log_err(["Failed to copy db from dest to temp: ", SQL_DB_DEST.path, " -> ", SQL_DB_TEMP.path])
		return false
	Logger.log_msg(["Loaded SQLSave: ", SQL_DB_DEST.path])
	return true

# Save everything, leave savePath empty if you want to overwrite save
func Save(savePath:String = "") -> bool:
	if(savePath == ""): savePath = SQL_DB_DEST.path
	if(FileUtils.file_exists(savePath)):
		if(OS.move_to_trash(ProjectSettings.globalize_path(savePath)) != OK):
			Logger.log_err(["Unable to delete SQLSave save file: ", savePath])
			return false
	
	var result := FileUtils.copy_file(SQL_DB_TEMP.path, savePath)
	if(not result == OK):
		Logger.log_err(["Failed to copy db from temp to save: ", SQL_DB_TEMP.path, " -> ", savePath, ", result: ", result])
		return false
	
	SQLiteWrapper.do_query_on_path(savePath, "VACUUM;")
	Logger.log_msg(["Saved SQLSave: ", savePath])
	return true

# Deletes TEMP file
func close() -> int:
	var result := SQL_DB_TEMP.delete_file()
	if(result != OK):
		Logger.log_err(["Failed to close SQLSave: ", SQL_DB_DEST.path, ", err: ", result])
		return result
	Logger.log_msg(["Closed SQLSave: ", SQL_DB_DEST.path])
	return result

func delete() -> int:
	var result:int
	if(FileUtils.file_exists(SQL_DB_TEMP.path)):
		result = close()
		if(result != OK):
			Logger.log_err(["Failed to delete SQLSave on close: ", SQL_DB_DEST.path, ", err: ", result])
			return result
	
	result = SQL_DB_DEST.delete_file()
	if(result != OK):
		Logger.log_err(["Failed to delete SQLSave: ", SQL_DB_DEST.path, ", err: ", result])
		return result
	Logger.log_msg(["Deleted SQLSave: ", SQL_DB_DEST.path])
	return result

### ----------------------------------------------------
# GameData control
### ----------------------------------------------------

# Returns saved player data from save
func get_PlayerEntity() -> PlayerEntity:
	var PlayerEntityStr = SQL_DB_TEMP.sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	return PlayerEntity.new().from_str(PlayerEntityStr)

# Saves Player Entity
func set_PlayerEntity(Player:PlayerEntity) -> bool:
	SQL_DB_TEMP.sql_save_compressed( 
		Player.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	return true

### ----------------------------------------------------
# MapData control
### ----------------------------------------------------

# Returns saved or new map
func get_map(MapName:String) -> MapData:
	var loadStr := SQL_DB_TEMP.sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE],
		MapName)
	if(loadStr.is_empty()):
		Logger.log_msg(["Map: ", MapName, ", doesn't exist, return new empty."])
		var NewMap := MapData.new()
		NewMap.MapName = MapName
		return NewMap
	return MapData.new().from_string(loadStr)

# Saves a map
func set_map(MapRef:MapData) -> void:
	SQL_DB_TEMP.sql_save_compressed(
		MapRef.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE],
		MapRef.MapName)

### ----------------------------------------------------
# STATIC
### ----------------------------------------------------

# Cleans all temp files from save folders (Dont call when a save is used!)
static func clean_TEMP(folderPath:String) -> bool:
	var isOK := true
	for fileData in FileUtils.get_dirs_FileData(folderPath):
		if TEMP_MARKER in fileData.name:
			isOK = isOK and (FileUtils.delete_file(fileData.path) == OK)
	return isOK