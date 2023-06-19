### ----------------------------------------------------
# Handles communication with SQLite
# Makes stuff easier to read but is slower than direct SQLite
### ----------------------------------------------------

extends RefCounted
class_name SQLiteWrapper

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SQLCOMPRESSION = 2

var TABLE_KEY:String
var TABLE_COMPRESSED_DATA:String
var TABLE_DECOMPRESSED_SIZE:String

var SQL_GLOBAL := SQLite.new()
var path:String

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(
	pathToDB:String, 
	tableKeyColumnName:String,
	tableCompressedDataColumnName:String,
	tableCompressedDataSizeColumnName:String,
	verbosity:int, 
	isReadOnly:bool
) -> void:
	SQL_GLOBAL.verbosity_level = verbosity
	SQL_GLOBAL.path = pathToDB
	SQL_GLOBAL.read_only = isReadOnly

	TABLE_KEY = tableKeyColumnName
	TABLE_COMPRESSED_DATA = tableCompressedDataColumnName
	TABLE_DECOMPRESSED_SIZE = tableCompressedDataSizeColumnName

	path = pathToDB

func has_file() -> bool:
	return FileUtils.file_exists(path)

func delete_file() -> int:
	return FileUtils.delete_file(path)

func create_new_file() -> int:
	return FileUtils.create_empty_file(path)

# Compresses and saves data in sqlite db
# Designed to compress big data chunks
func sql_save_compressed(Str:String, tableName:String, Key:String) -> void:
	var B64C := Algorithms.compress_str(Str, SQLCOMPRESSION)
	var values:String = "'" + Key + "','" + B64C + "','" + str(Str.length()) + "'"
	do_query("REPLACE INTO "+tableName+" ("+TABLE_KEY+","+TABLE_COMPRESSED_DATA+","+TABLE_DECOMPRESSED_SIZE+") VALUES("+values+");")

# Loads chunk from save, returns empty string if position not saved
func sql_load_compressed(tableName:String, KeyVar:String) -> String:
	if (not row_exists(tableName, TABLE_KEY, str(KeyVar))): return ""
	var queryResult := get_query_result("SELECT "+TABLE_COMPRESSED_DATA+","+TABLE_DECOMPRESSED_SIZE+" FROM "+tableName+" WHERE "+TABLE_KEY+"='"+KeyVar+"';")
	return Algorithms.decompress_str(queryResult[0][TABLE_COMPRESSED_DATA], SQLCOMPRESSION, queryResult[0][TABLE_DECOMPRESSED_SIZE])

# Tries to get dict form saved data, returns empty dict on fail
func get_dict_from_table(tableName:String, keyVar) -> Dictionary:
	var tempVar = str_to_var(sql_load_compressed(tableName, keyVar))
	if(not tempVar is Dictionary):
		return Dictionary()
	return tempVar

### ----------------------------------------------------
# Queries, these are not meant to be used where speed matters (open and close db in every function which is slow)
### ----------------------------------------------------

# tableDict format:
# { columnName:{"data_type":"text", "not_null": true}, ... }
func add_table(tableName:String, tableDict:Dictionary) -> bool:
	var isOk := true
	SQL_GLOBAL.open_db()
	isOk = SQL_GLOBAL.create_table(tableName, tableDict) and isOk
	SQL_GLOBAL.close_db()

	if(not isOk):
		Logger.log_err(["Unable to create table: ", tableName])
		return false
	return isOk

func table_exists(tableName:String) -> bool:
	var QuerryResult := get_query_result("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
	return QuerryResult.size()>0

func column_exists(tableName:String, columnName:String) -> bool:
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
	if(not column_exists(tableName, columnName)):
		Logger.log_err(["Column doesnt exist in table: ", tableName, ", ", columnName])
		return false
	
	var QuerryResult := get_query_result("SELECT EXISTS(SELECT 1 FROM " + tableName + " WHERE " + columnName + "='" + value + "') LIMIT 1;")
	return QuerryResult[0].values().has(1)

func get_query_result(query:String) -> Array:
	SQL_GLOBAL.open_db()
	SQL_GLOBAL.query(query)
	SQL_GLOBAL.close_db()
	return SQL_GLOBAL.query_result

func do_query(query:String) -> void:
	SQL_GLOBAL.open_db()
	SQL_GLOBAL.query(query)
	SQL_GLOBAL.close_db()

### ----------------------------------------------------
# STATIC
### ----------------------------------------------------

# Deletes an sql DB
static func delete_SQLDB_file(folderPath:String, dbName:String) -> int:
	return FileUtils.delete_file(folderPath + dbName + ".db")

static func do_query_on_path(pathToDB:String, query:String) -> void:
	var sqlite = SQLite.new()
	sqlite.path = pathToDB
	sqlite.verbosity_level = SQLite.QUIET
	
	sqlite.open_db()
	sqlite.query(query)
	sqlite.close_db()

static func get_query_on_path(pathToDB:String, query:String) -> Array:
	var sqlite = SQLite.new()
	sqlite.path = pathToDB
	sqlite.verbosity_level = SQLite.QUIET
	
	sqlite.open_db()
	sqlite.query(query)
	sqlite.close_db()
	return sqlite.query_result
