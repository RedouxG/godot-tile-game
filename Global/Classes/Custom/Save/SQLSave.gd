### ----------------------------------------------------
# Manages SQLite
# 	SQLSave is a main save file that stores save data which consists of:
# 	- PlayerData (GAMEDATA_TABLE -> PLAYER_DATA)
# 	- EditedMaps (GAMEDATA_TABLE -> MapName)
# To setup a save use create_new_save() and initialize()
# To load use load()
# To save use save()
### ----------------------------------------------------

extends "res://Global/Classes/Custom/Save/SQLSaveBase.gd"
class_name SQLSave

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(fileName:String, fileDir:String, verbose = false) -> void:
	_setupDB(fileName, fileDir, verbose)

# Should be called after init before trying to acess data from save
func load() -> bool:
	if(not LibK.Files.file_exist(DEST_PATH)):
		Logger.logErr(["Tried to init non existing save: ", DEST_PATH], get_stack())
		return false
	if(LibK.Files.copy_file(DEST_PATH, TEMP_PATH) != OK):
		Logger.logErr(["Failed to copy db from dest to temp: ", DEST_PATH, " -> ", TEMP_PATH], get_stack())
		return false
	Logger.logMS(["Loaded SQLSave: ", DEST_PATH])
	return true

# Save everything, leave savePath empty if you want to overwrite save
func save(savePath:String = "") -> bool:
	if(savePath == ""): savePath = DEST_PATH
	if(LibK.Files.file_exist(savePath)):
		if(OS.move_to_trash(ProjectSettings.globalize_path(savePath)) != OK):
			Logger.logErr(["Unable to delete save file: ", savePath], get_stack())
			return false
	
	var result := LibK.Files.copy_file(TEMP_PATH, savePath)
	if(not result == OK):
		Logger.logErr(["Failed to copy db from temp to save: ", TEMP_PATH, " -> ", savePath, ", result: ", result], get_stack())
		return false
	
	SQL_DB_GLOBAL.path = savePath
	do_query("VACUUM;") # Vacuum save to reduce its size
	SQL_DB_GLOBAL.path = TEMP_PATH

	Logger.logMS(["Saved SQLSave: ", savePath])
	return true

### ----------------------------------------------------
# GameData control
### ----------------------------------------------------

# Returns saved player data from save
func get_PlayerEntity() -> PlayerEntity:
	var PlayerEntityStr = _sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	return PlayerEntity.new().from_str(PlayerEntityStr)

# Saves Player Entity
func set_PlayerEntity(Player:PlayerEntity) -> bool:
	_sql_save_compressed( 
		Player.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		GAMEDATA_KEYS.keys()[GAMEDATA_KEYS.PLAYER_DATA])
	return true

### ----------------------------------------------------
# MapData control
### ----------------------------------------------------

# On fail just load empty
func get_map(MapName:String) -> MapData:
	var loadStr := _sql_load_compressed(
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		MapName)
	if(loadStr.is_empty()):
		Logger.logMS(["Map: ", MapName, ", doesn't exist, return new empty."])
		return MapData.new()
	return MapData.new().from_str(loadStr)

func set_map(MapRef:MapData) -> void:
	_sql_save_compressed(
		MapRef.to_string(),
		TABLE_NAMES.keys()[TABLE_NAMES.GAMEDATA_TABLE],
		MapRef.MapName)
