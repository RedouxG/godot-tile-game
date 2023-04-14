### ----------------------------------------------------
# DESC
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TEMP_FOLDER := "res://Resources/Maps/Templates/"
const EDIT_FOLDER := "res://Resources/Maps/Saves/"

# Currently loaded save
var SQLSaveDB:SQLSave

# Template of the map, not editable
var MapTemp:MapData

# Loaded map from save, editable
var MapEdit:MapData

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func make_new_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var NewMapTemp := MapData.get_new(MapName)
	var result := MapData.save_MapData_to_path(path, NewMapTemp)
	if(result != OK):
		Logger.logErr(["Failed to create new MapTemp, path: ", path])
		return false
	Logger.LogMsg(["Created new MapTemp: ", MapName])
	return true

func _load_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var TempResult := MapData.load_MapData_from_path(path)
	if(TempResult == null):
		Logger.logErr(["Failed to load MapTemp from path: ", path])
		return false
	MapTemp = TempResult
	Logger.LogMsg(["Loaded MapTemp: ", MapTemp.MapName])
	return true

func _save_MapTemp() -> bool:
	var path := TEMP_FOLDER + MapTemp.MapName + ".res"
	var result := MapData.save_MapData_to_path(path, MapTemp)
	if(result != OK):
		Logger.logErr(["Failed to save MapTemp to path: ", path])
		return false
	return true

func _delete_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var result := FileManager.delete_file(path)
	if(result != OK):
		Logger.logErr(["Failed to delete MapTemp, path: ", path,", err: ", result])
		return false
	Logger.LogMsg(["Deleted MapTemp from path: ", path])
	return true

### ----------------------------------------------------
# SQLSaveDB
### ----------------------------------------------------

# Creates a new save
func make_new_save(SaveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, SaveName)
	return TempSave.create_new_save()

func load_save(SaveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, SaveName)
	if(not TempSave.Load()):
		Logger.logErr(["Failed to load save to SaveManager: ", SaveName])
		return false
	if(SQLSaveDB != null):
		SQLSaveDB.close()
	SQLSaveDB = TempSave
	return true

func save_save(savePath:String = "") -> bool:
	if(not SQLSaveDB.save(savePath)):
		Logger.logErr(["Failed to save save in SaveManager: ", SQLSaveDB.SQL_DB_DEST.path])
		return false
	return true

# Changes current map, saves MapEdit
func change_map(MapName:String) -> bool:
	if(not _load_MapTemp(MapName)):
		Logger.logErr(["Failed to change map in SaveManager: ", MapName])
		return false
	if(MapEdit != null):
		SQLSaveDB.set_map(MapEdit)
	MapEdit = SQLSaveDB.get_map(MapName)
	return true
