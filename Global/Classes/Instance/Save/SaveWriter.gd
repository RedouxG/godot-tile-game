### ----------------------------------------------------
# Manages SQLite
# 	Stores save data which consists of:
# 	- PlayerData (GAMEDATA_TABLE -> PLAYER_DATA)
# 	- EditedMaps (GAMEDATA_TABLE -> mapName)
# To setup a save use create_new_save() and initialize()
# To load use open()
# To save use Save()
### ----------------------------------------------------

extends SaveReader
class_name SaveWriter

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const TEMP_MARKER = "_TEMP" # Added to ending of all temp files

### ----------------------------------------------------
# Functions
### ----------------------------------------------------
 
func _init(fileDir:String, fileName:String, verbose = false) -> void:
	_initialize(fileDir, fileName, verbose)

func _initialize(fileDir:String, fileName:String, verbose:bool) -> void:
	beVerbose = verbose
	FILE_DIR = fileDir
	FILE_NAME = fileName
	
	SQL_DB_TEMP = SQLiteWrapper.new(
		FILE_DIR + FILE_NAME + TEMP_MARKER + ".db",
		TABLE_KEY,
		TABLE_COMPRESSED_DATA,
		TABLE_DECOMPRESSED_SIZE,
		SQLite.QUIET,
		false
	)
	
	SQL_DB_DEST = SQLiteWrapper.new(
		FILE_DIR + FILE_NAME + ".db",
		TABLE_KEY,
		TABLE_COMPRESSED_DATA,
		TABLE_DECOMPRESSED_SIZE,
		SQLite.QUIET,
		false
	)

func is_open() -> bool:
	return SQL_DB_TEMP.has_file()

# If save already exists, create a new one and delete old
func create_new_save() -> bool:
	if(SQL_DB_DEST.has_file()):
		if(SQL_DB_DEST.delete_file() != OK):
			Logger.log_err(["Unable to delete save file: ", SQL_DB_DEST.path])
			return false
	
	var result := SQL_DB_DEST.create_new_file()
	if(result != OK):
		Logger.log_err(["Unable to create empty SQLSave save file: ", SQL_DB_DEST.path, ", err: ", result])
		return false
	
	var isOk := true
	for TID in TABLE_NAMES.values():
		var tableName:String = TABLE_NAMES.keys()[TID]
		isOk = isOk and SQL_DB_DEST.add_table(tableName, TABLE_CONTENT)
	
	_init_GAMEDATA_TABLE()
	isOk = isOk and open()

	Logger.log_result(isOk, ["Creating new SQLite save: ", SQL_DB_DEST.path])
	return isOk

func _init_GAMEDATA_TABLE() -> void:
	var TemplatePlayer := PlayerEntity.new()
	SQL_DB_DEST.sql_save_compressed(
		TemplatePlayer.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	TemplatePlayer.free()

# Should be called after init before trying to acess data from save
func open() -> bool:
	if(not has_file()):
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
	if(not is_open()):
		Logger.log_err([Logging.Errors.NO_ACCESS("set map", "save is not open")])
		return false

	if(FileUtils.file_exists(savePath)):
		if(OS.move_to_trash(ProjectSettings.globalize_path(savePath)) != OK):
			Logger.log_err(["Unable to delete SQLSave save file: ", savePath])
			return false
	
	var result := FileUtils.copy_file(SQL_DB_TEMP.path, savePath)
	if(not result == OK):
		Logger.log_err(["Failed to copy db from temp to save: ", SQL_DB_TEMP.path, " -> ", savePath, ", result: ", result])
		return false
	
	var isOk := SQLiteWrapper.do_query_on_path(savePath, "VACUUM;")
	Logger.log_result(isOk, ["Trying to save: ", savePath])
	return isOk

# Deletes TEMP file
func close() -> int:
	var result := SQL_DB_TEMP.delete_file()
	Logger.log_result_code(result, ["Trying to close SQLite: ", SQL_DB_DEST.path])
	return result

func delete() -> int:
	var result:int
	if(FileUtils.file_exists(SQL_DB_TEMP.path)):
		result = close()
		if(result != OK):
			Logger.log_err(["Failed to delete SQLSave on close: ", SQL_DB_DEST.path, ", err: ", result])
			return result
	
	result = SQL_DB_DEST.delete_file()
	Logger.log_result_code(result, ["Trying to delete SQLite: ", SQL_DB_DEST.path])
	return result

### ----------------------------------------------------
# GameData control
### ----------------------------------------------------

func set_PlayerEntity(Player:PlayerEntity) -> bool:
	if(not is_open()):
		Logger.log_err([Logging.Errors.NO_ACCESS("set map", "save is not open")])
		return false
	
	return SQL_DB_TEMP.sql_save_compressed(
		Player.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])

func set_map(MapRef:MapData) -> bool:
	if(not is_open()):
		Logger.log_err([Logging.Errors.NO_ACCESS("set map", "save is not open")])
		return false

	return SQL_DB_TEMP.sql_save_compressed(
		MapRef.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE],
		MapRef.mapName)

func set_new_empty_map(mapName:String) -> bool:
	var map := MapData.get_new(mapName)
	return set_map(map)

### ----------------------------------------------------
# STATIC
### ----------------------------------------------------

# Cleans all temp files from save folders (Dont call when a save is used!)
static func clean_TEMP(folderPath:String) -> bool:
	var isOk := true
	for fileData in FileUtils.get_dirs_FileData(folderPath):
		if TEMP_MARKER in fileData.name:
			isOk = isOk and (FileUtils.delete_file(fileData.path) == OK)
	return isOk
