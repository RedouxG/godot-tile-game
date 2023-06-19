### ----------------------------------------------------
# Manages SQLite in read only mode
# 	File that stores save data which consists of:
# 	- PlayerData (GAMEDATA_TABLE -> PLAYER_DATA)
# 	- EditedMaps (GAMEDATA_TABLE -> MapName)
### ----------------------------------------------------

extends RefCounted
class_name SaveReader

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

# Names of all tables that need to be created
enum TABLE_NAMES {GAMEDATA_TABLE, MAPDATA_TABLE}
# Keys in GameData table (compressed dicts are values)
enum GAMEDATA_KEYS {PLAYER_DATA}

# Content of all tables
const TABLE_KEY = "Key"
const TABLE_COMPRESSED_DATA = "CompressedData"
const TABLE_DECOMPRESSED_SIZE = "DecompressedSize"

const TABLE_CONTENT = { 
	TABLE_KEY:
		{"primary_key":true,"data_type":"text", "not_null": true},
	TABLE_COMPRESSED_DATA:
		{"data_type":"text", "not_null": true},
	TABLE_DECOMPRESSED_SIZE:
		{"data_type":"int", "not_null": true},
}

# Temp save is used as proxy file for save
# since save is managed via sql it needs to edit a file
# TEMP file is temporary file that is currently being used and edited
# DEST file is destination file that holds final save and is not editable
var SQL_DB_TEMP:SQLiteWrapper # Source of data, temporary file
var SQL_DB_DEST:SQLiteWrapper # The main save file 

var FILE_NAME:String	    # Name of the database file
var FILE_DIR:String         # Database file dir
var beVerbose:bool

### ----------------------------------------------------
# Functions
### ----------------------------------------------------
 
func _init(fileDir:String, fileName:String, verbose := false) -> void:
	_initialize(fileDir, fileName, verbose)

func _initialize(fileDir:String, fileName:String, verbose:bool) -> void:
	beVerbose = verbose
	FILE_DIR = fileDir
	FILE_NAME = fileName
	
	SQL_DB_DEST = SQLiteWrapper.new(
		FILE_DIR + FILE_NAME + ".db",
		TABLE_KEY,
		TABLE_COMPRESSED_DATA,
		TABLE_DECOMPRESSED_SIZE,
		SQLite.QUIET,
		true,
	)
	
	SQL_DB_TEMP = SQL_DB_DEST

func exists() -> bool:
	return SQL_DB_DEST.has_file()

### ----------------------------------------------------
# GameData control
### ----------------------------------------------------

func get_PlayerEntity() -> PlayerEntity:
	var PlayerEntityStr = SQL_DB_TEMP.sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA]
	)
	return PlayerEntity.new().from_str(PlayerEntityStr)

func get_map_exists(MapName:String) -> bool:
	var result := SQL_DB_TEMP.row_exists(
		TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE],
		TABLE_KEY, 
		MapName
	)
	return result

func get_map(MapName:String) -> MapData:
	if(not get_map_exists(MapName)):
		Logger.log_err(["Map: ", MapName, ", doesn't exist."])
		return null
	
	var loadStr := SQL_DB_TEMP.sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE],
		MapName
	)
	return MapData.new().from_string(loadStr)
