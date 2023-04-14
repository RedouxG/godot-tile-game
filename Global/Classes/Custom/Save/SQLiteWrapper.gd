### ----------------------------------------------------
# Handles communication with SQLite
# Makes stuff easier to read but is slower than direct SQLite
### ----------------------------------------------------

extends RefCounted
class_name SQLiteWrapper

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SQLCOMPRESSION = 2
var SQL_GLOBAL := SQLite.new()
var path:String

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(pathToDB:String, verbosity:int) -> void:
	SQL_GLOBAL.verbosity_level = verbosity
	SQL_GLOBAL.path = pathToDB
	path = pathToDB

func has_file() -> bool:
	return FileManager.file_exist(path)

func delete_file() -> int:
	return FileManager.delete_file(path)

func create_new_file() -> int:
	return FileManager.create_empty_file(path)

# Compresses and saves data in sqlite db
# Designed to compress big data chunks
func sql_save_compressed(Str:String, tableName:String, KeyVar) -> void:
	var B64C := LibK.Compression.compress_str(Str, SQLCOMPRESSION)
	var values:String = "'" + str(KeyVar) + "','" + B64C + "','" + str(Str.length()) + "'"
	do_query("REPLACE INTO "+tableName+" (Key,CData,DCSize) VALUES("+values+");")

# Loads chunk from save, returns empty string if position not saved
func sql_load_compressed(tableName:String, KeyVar) -> String:
	if (not row_exists(tableName, "Key", str(KeyVar))): return ""
	var queryResult := get_query_result("SELECT CData,DCSize FROM "+tableName+" WHERE Key='"+str(KeyVar)+"';")
	return LibK.Compression.decompress_str(queryResult[0]["CData"], SQLCOMPRESSION, queryResult[0]["DCSize"])

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
	var isOK := true
	SQL_GLOBAL.open_db()
	isOK = SQL_GLOBAL.create_table(tableName, tableDict) and isOK
	SQL_GLOBAL.close_db()

	if(not isOK):
		Logger.logErr(["Unable to create table: ", tableName])
		return false
	return isOK

func table_exists(tableName:String) -> bool:
	var QuerryResult := get_query_result("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
	return QuerryResult.size()>0

func column_exists(tableName:String, columnName:String) -> bool:
	if(not table_exists(tableName)):
		Logger.logErr(["Table doesnt exist: ", tableName])
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
		Logger.logErr(["Column doesnt exist in table: ", tableName, ", ", columnName])
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
static func delete_SQLDB_file(folderPath:String ,dbName:String) -> int:
	return FileManager.delete_file(folderPath + dbName + ".db")

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
