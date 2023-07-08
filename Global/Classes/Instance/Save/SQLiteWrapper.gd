### ----------------------------------------------------
# Handles communication with SQLite
# Makes stuff easier to read but is slower than direct SQLite
### ----------------------------------------------------

extends RefCounted
class_name SQLiteWrapper

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var SQL_GLOBAL := SQLite.new()

var tableKey:String
var tableCompressedData:String
var tableDecompressedSize:String
var path:String

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(
    _path:String, 
    _tableKey:String,
    _tableCompressedData:String,
    _tableDecompressedSize:String,
    verbosity:int, 
    isReadOnly:bool
) -> void:
    SQL_GLOBAL.verbosity_level = verbosity
    SQL_GLOBAL.path = _path
    SQL_GLOBAL.read_only = isReadOnly

    tableKey = _tableKey
    tableCompressedData = _tableCompressedData
    tableDecompressedSize = _tableDecompressedSize

    path = _path

func has_file() -> bool:
    return FileUtils.file_exists(path)

func delete_file() -> int:
    return FileUtils.delete_file(path)

func create_new_file() -> int:
    return FileUtils.create_empty_file(path)

# Compresses and saves data in sqlite db
# Designed to compress big data chunks
func sql_save_compressed(Str:String, tableName:String, Key:String) -> bool:
    var B64C := StringUtils.compress_str(Str, FileAccess.COMPRESSION_ZSTD)
    var values:String = "'" + Key + "','" + B64C + "','" + str(Str.length()) + "'"
    return do_query("REPLACE INTO "+tableName+" ("+tableKey+","+tableCompressedData+","+tableDecompressedSize+") VALUES("+values+");")

# Loads chunk from save, returns empty string if position not saved
func sql_load_compressed(tableName:String, KeyVar:String) -> String:
    if (not row_exists(tableName, tableKey, str(KeyVar))): return ""
    var queryResult := get_query_result("SELECT "+tableCompressedData+","+tableDecompressedSize+" FROM "+tableName+" WHERE "+tableKey+"='"+KeyVar+"';")
    return StringUtils.decompress_str(queryResult[0][tableCompressedData], FileAccess.COMPRESSION_ZSTD, queryResult[0][tableDecompressedSize])

### ----------------------------------------------------
# Queries, these are not meant to be used where speed matters (open and close db in every function which is slow)
### ----------------------------------------------------

# tableDict format:
# { columnName:{"data_type":"text", "not_null": true}, ... }
func add_table(tableName:String, tableDict:Dictionary) -> bool:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(path)])
        return false
    
    var isOk := true
    isOk = isOk and SQL_GLOBAL.open_db()
    isOk = isOk and SQL_GLOBAL.create_table(tableName, tableDict)
    isOk = isOk and SQL_GLOBAL.close_db()

    if(not isOk):
        Logger.log_err(["Unable to create table: ", tableName])
    return isOk

func table_exists(tableName:String) -> bool:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(path)])
        return false
    
    var QuerryResult := get_query_result("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
    return QuerryResult.size()>0

func column_exists(tableName:String, columnName:String) -> bool:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(path)])
        return false
    
    if(not table_exists(tableName)):
        Logger.log_err(["Table doesnt exist: ", tableName])
        return false 
    
    var exists := false
    var QuerryResult := get_query_result("PRAGMA table_info('" + tableName + "');")
    for element in QuerryResult:
        if element["name"] == columnName: 
            exists = true
            break
    
    return exists

func row_exists(tableName:String, columnName:String, value:String) -> bool:
    if(not has_file()):
        Logger.log_err([Logging.Errors.NO_FILE(path)])
        return false
    
    if(not column_exists(tableName, columnName)):
        Logger.log_err(["Column doesnt exist in table: ", tableName, ", ", columnName])
        return false
    
    var QuerryResult := get_query_result("SELECT EXISTS(SELECT 1 FROM " + tableName + " WHERE " + columnName + "='" + value + "') LIMIT 1;")
    return QuerryResult[0].values().has(1)

func get_query_result(query:String) -> Array:
    var isOk := true
    isOk = isOk and SQL_GLOBAL.open_db()
    isOk = isOk and SQL_GLOBAL.query(query)
    isOk = isOk and SQL_GLOBAL.close_db()
    if(not isOk):
        return []
    return SQL_GLOBAL.query_result

func do_query(query:String) -> bool:
    var isOk := true
    isOk = isOk and SQL_GLOBAL.open_db()
    isOk = isOk and SQL_GLOBAL.query(query)
    isOk = isOk and SQL_GLOBAL.close_db()
    return isOk

static func do_query_on_path(pathToDB:String, query:String) -> bool:
    var sqlite = SQLite.new()
    sqlite.path = pathToDB
    sqlite.verbosity_level = SQLite.QUIET
    
    var isOk := true
    isOk = isOk and sqlite.open_db()
    isOk = isOk and sqlite.query(query)
    isOk = isOk and sqlite.close_db()
    return isOk

static func get_query_on_path(pathToDB:String, query:String) -> Array:
    var sqlite = SQLite.new()
    sqlite.path = pathToDB
    sqlite.verbosity_level = SQLite.QUIET
    
    var isOk := true
    isOk = isOk and sqlite.open_db()
    isOk = isOk and sqlite.query(query)
    isOk = isOk and sqlite.close_db()
    if(not isOk):
        return []
    return sqlite.query_result
