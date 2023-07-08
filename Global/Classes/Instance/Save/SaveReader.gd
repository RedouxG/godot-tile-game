### ----------------------------------------------------
# Manages SQLite in read only mode
#     File that stores save data which consists of:
#     - PlayerData (GAMEDATA_TABLE -> PLAYER_DATA)
#     - EditedMaps (GAMEDATA_TABLE -> mapName)
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

var fileName:String
var fileDir:String
var verbose:bool

### ----------------------------------------------------
# Functions
### ----------------------------------------------------
 
func _init(_fileDir:String, _fileName:String, _verbose := false) -> void:
    _initialize(_fileDir, _fileName, _verbose)

func _initialize(_fileDir:String, _fileName:String, _verbose:bool) -> void:
    self.verbose = _verbose
    self.fileDir = _fileDir
    self.fileName = _fileName
    
    SQL_DB_DEST = SQLiteWrapper.new(
        fileDir + fileName + ".db",
        TABLE_KEY,
        TABLE_COMPRESSED_DATA,
        TABLE_DECOMPRESSED_SIZE,
        SQLite.QUIET,
        true,
    )
    
    SQL_DB_TEMP = SQL_DB_DEST

func has_file() -> bool:
    return SQL_DB_DEST.has_file()

### ----------------------------------------------------
# GameData control
### ----------------------------------------------------

func get_PlayerEntity() -> PlayerEntity:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(SQL_DB_DEST.path)])
        return null

    var PlayerEntityStr = SQL_DB_TEMP.sql_load_compressed(
        TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
        GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA]
    )
    return PlayerEntity.new().from_str(PlayerEntityStr)

func get_map_exists(mapName:String) -> bool:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(SQL_DB_DEST.path)])
        return false
    
    return SQL_DB_TEMP.row_exists(
        TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE], TABLE_KEY, mapName)

func get_map(mapName:String) -> MapData:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(SQL_DB_DEST.path)])
        return null
    
    if(not get_map_exists(mapName)):
        Logger.log_err(["Map: ", mapName, ", doesn't exist."])
        return null
    
    var loadStr := SQL_DB_TEMP.sql_load_compressed(
        TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE], mapName)
    return MapData.new().from_string(loadStr)

func _to_string() -> String:
    return fileDir + fileName + ".db"
