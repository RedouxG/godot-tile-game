### ----------------------------------------------------
# Handles communication with SQLite directly
### ----------------------------------------------------

extends RefCounted

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Names of all tables that need to be created
enum TABLE_NAMES {GAMEDATA_TABLE}
# Keys in GameData table (compressed dicts are values)
enum GAMEDATA_KEYS {PLAYER_DATA}

# Content of all tables
const TABLE_CONTENT = { 
	"Key":{"primary_key":true,"data_type":"text", "not_null": true},
	"CData":{"data_type":"text", "not_null": true},
	"DCSize":{"data_type":"int", "not_null": true},
}

const SQLCOMPRESSION = 2
const TEMP_MARKER = "_TEMP" # Added to ending of all temp files

var SQL_DB_GLOBAL:SQLite    # SQLite object assigned to SaveManager
var DEST_PATH:String        # The main save file path
var TEMP_PATH:String	    # Temp save file path
var FILE_NAME:String	    # Name of the database file
var FILE_DIR:String         # Database file dir
var beVerbose:bool          # For debug purposes

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _setupDB(fileName:String, fileDir:String, verbose = false):
	beVerbose = verbose
	FILE_DIR = fileDir
	FILE_NAME = fileName
	DEST_PATH = FILE_DIR + FILE_NAME + ".db"
	TEMP_PATH = FILE_DIR + FILE_NAME + TEMP_MARKER + ".db"

	SQL_DB_GLOBAL = SQLite.new()
	SQL_DB_GLOBAL.verbosity_level = 0
	SQL_DB_GLOBAL.path = TEMP_PATH

# Deletes TEMP file
func close() -> bool:
	return (LibK.Files.delete_file(TEMP_PATH) != OK)

func _init_GAMEDATA_TABLE() -> void:
	var TemplatePlayer := PlayerEntity.new()
	_sql_save_compressed(
		TemplatePlayer.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	TemplatePlayer.free()

# Compresses and saves data in sqlite db
# Designed to compress big data chunks
func _sql_save_compressed(Str:String, tableName:String, KeyVar) -> void:
	var B64C := LibK.Compression.compress_str(Str, SQLCOMPRESSION)
	var values:String = "'" + str(KeyVar) + "','" + B64C + "','" + str(Str.length()) + "'"
	do_query("REPLACE INTO "+tableName+" (Key,CData,DCSize) VALUES("+values+");")

	if(beVerbose): Logger.logMS(["Saved CData to SQLite: ", tableName, " ", KeyVar])

# Loads chunk from save, returns empty string if position not saved
func _sql_load_compressed(tableName:String, KeyVar) -> String:
	if (not row_exists(tableName, "Key", str(KeyVar))): return ""
	var queryResult := get_query_result("SELECT CData,DCSize FROM "+tableName+" WHERE Key='"+str(KeyVar)+"';")

	if(beVerbose): Logger.logMS(["Loaded CData from SQLite: ", tableName, " ", KeyVar])
	return LibK.Compression.decompress_str(queryResult[0]["CData"], SQLCOMPRESSION, queryResult[0]["DCSize"])

# If save already exists, create a new one and put old one in the trash
func create_new_save() -> bool:
	if(LibK.Files.file_exist(DEST_PATH)):
		if(LibK.Files.delete_file(DEST_PATH) != OK):
			Logger.logErr(["Unable to delete save file: ", DEST_PATH], get_stack())
			return false

	var result := LibK.Files.create_empty_file(DEST_PATH)
	if(result != OK):
		Logger.logErr(["Unable to create empty save file: ", DEST_PATH, ", err: ", result], get_stack())
		return false

	SQL_DB_GLOBAL.path = DEST_PATH # Save everything in destination instead of temp file
	var isOK := true
	for TID in TABLE_NAMES.values():
		var tableName:String = TABLE_NAMES.keys()[TID]
		isOK = isOK and add_table(tableName, TABLE_CONTENT)
	
	_init_GAMEDATA_TABLE()
	SQL_DB_GLOBAL.path = TEMP_PATH

	if(not isOK): Logger.logErr(["Failed to create tables: ", DEST_PATH], get_stack())
	elif(isOK):   Logger.logMS(["Created DataBase at: ", DEST_PATH])
	return isOK

# Deletes an sql DB
static func delete_SQLDB_file(folderPath:String ,dbName:String) -> int:
	return LibK.Files.delete_file(folderPath + dbName + ".db")

# Cleans all temp files from save folders (Dont call when a save is used!)
static func clean_TEMP(folderPath:String) -> bool:
	var isOK := true
	for packed in LibK.Files.get_file_list_at_dir(folderPath):
		var filepath:String = packed[0]
		var fileName:String = packed[1]
		if TEMP_MARKER in fileName:
			isOK = isOK and (LibK.Files.delete_file(filepath) == OK)
	return isOK

# Tries to get dict form saved data, returns empty dict on fail
func _get_dict_from_table(tableName:String, keyVar) -> Dictionary:
	var tempVar = str_to_var(_sql_load_compressed(tableName, keyVar))
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
	SQL_DB_GLOBAL.open_db()
	isOK = SQL_DB_GLOBAL.create_table(tableName, tableDict) and isOK
	SQL_DB_GLOBAL.close_db()

	if(not isOK):
		Logger.logErr(["Unable to create table: ", tableName], get_stack())
		return false

	if(beVerbose): Logger.logMS(["Created table: ", tableName])
	return isOK

func table_exists(tableName:String) -> bool:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result.size()>0

func column_exists(tableName:String, columnName:String) -> bool:
	var exists := false
	if(not table_exists(tableName)):
		Logger.logErr(["Table doesnt exist: ", tableName], get_stack())
		return false 
	
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("PRAGMA table_info('" + tableName + "');")
	for element in SQL_DB_GLOBAL.query_result:
		if element["name"] == columnName: 
			exists = true
			break
	
	SQL_DB_GLOBAL.close_db()
	return exists

func row_exists(tableName:String, columnName:String, value:String) -> bool:
	if(not column_exists(tableName, columnName)):
		Logger.logErr(["Column doesnt exist in table: ", tableName, ", ", columnName], get_stack())
		return false
	
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("SELECT EXISTS(SELECT 1 FROM " + tableName + " WHERE " + columnName + "='" + value + "') LIMIT 1;")
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result[0].values().has(1)

func get_query_result(query:String) -> Array:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query(query)
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result

func do_query(query:String) -> void:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query(query)
	SQL_DB_GLOBAL.close_db()
