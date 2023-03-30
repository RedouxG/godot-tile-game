### ----------------------------------------------------
# DESC
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TEMP_FOLDER := "res://Resources/Templates/"
const EDIT_FOLDER := "res://Resources/Saves/"

# Currently loaded save
var SQLSaveDB:SQLSave

# Template of the map, not editable
var MapTemp:MapData

# Loaded map from save, editable
var MapEdit:MapData

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func load_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var TempResult := load_MapData_from_path(path)
	if(TempResult == null):
		Logger.logErr(["Failed to load MapTemp from path: ", path], get_stack())
		return false
	MapTemp = TempResult
	Logger.logMS(["Loaded MapTemp: ", MapTemp.MapName])
	return true

func load_MapEdit(MapName:String) -> bool:
	MapEdit = SQLSaveDB.get_map(MapName)
	return true

func save_MapTemp() -> bool:
	var path := TEMP_FOLDER + MapTemp.MapName + ".res"
	var result := save_MapData_to_path(path, MapTemp)
	if(result != OK):
		Logger.logErr(["Failed to save MapTemp to path: ", path], get_stack())
		return false
	return true

func save_MapEdit() -> bool:
	SQLSaveDB.set_map(MapEdit)
	return true

func load_save(SaveName:String) -> bool:
	var TempSave := SQLSave.new(SaveName, EDIT_FOLDER)
	if(not TempSave.load()):
		Logger.logErr(["Failed to load save: ", SaveName], get_stack())
		return false
	SQLSaveDB = TempSave
	return true

func save_save(savePath:String = "") -> bool:
	if(not SQLSaveDB.save(savePath)):
		Logger.logErr(["Failed to save save: ", SQLSaveDB.FILE_NAME], get_stack())
		return false
	return true

### ----------------------------------------------------
# Static util
### ----------------------------------------------------

func load_MapData_from_path(path:String) -> MapData:
	var TempRef = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if(not TempRef is MapData):
		return null
	return TempRef

func save_MapData_to_path(path:String, Map:MapData) -> int:
	return ResourceSaver.save(Map, path, ResourceSaver.FLAG_COMPRESS)
