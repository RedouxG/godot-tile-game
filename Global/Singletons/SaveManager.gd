### ----------------------------------------------------
# Manages save
# Usage:
# 1) Load SQLSaveDB via load_SQLSaveDB()
# 3) Change current map via change_map()
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
# API
### ----------------------------------------------------

# Sets MapTile in Data on posV3
func set_on(posV3:Vector3i, mapTile:MapTile) -> void:
	MapEdit.Data[posV3] = str(mapTile)

# Gets MapTile on position from Data
func get_on(posV3:Vector3i) -> MapTile:
	if(MapEdit.Data.has(posV3)):
		return MapTile.new().from_str(MapEdit.Data[posV3])
	return MapTemp.get_on(posV3)

# Removes position from Data
func rem_on(posV3:Vector3i) -> bool:
	return MapEdit.rem_on(posV3)

func set_terrain_on(posV3:Vector3i, terrainSetID:int, terrainID:int) -> void:
	MapEdit.set_terrain_on(posV3, terrainSetID, terrainID)

func rem_terrain_on(posV3:Vector3i, terrainSetID:int) -> void:
	MapEdit.rem_terrain_on(posV3, terrainSetID)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
	var MapEditChunk := MapEdit.get_chunk(chunkPos, chunkSize)
	var MapTempChunk := MapEdit.get_chunk(chunkPos, chunkSize)
	for posV3 in MapEditChunk:
		if(MapEditChunk.get(posV3) == null):
			MapEditChunk[posV3] = MapTempChunk.get(posV3)
	return MapEditChunk

### ----------------------------------------------------
# Save Management
### ----------------------------------------------------

func load_SQLSave(SaveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, SaveName)
	if(not TempSave.Load()):
		Logger.logErr(["Failed to load save to SaveManager: ", SaveName])
		return false
	if(SQLSaveDB != null):
		SQLSaveDB.close()
	SQLSaveDB = TempSave
	return true

func save_SQLSave(savePath:String = "") -> bool:
	_save_MapEdit()
	if(not SQLSaveDB.save(savePath)):
		Logger.logErr(["Failed to save save in SaveManager: ", SQLSaveDB.SQL_DB_DEST.path])
		return false
	return true

func change_map(MapName:String) -> bool:
	if(not _load_MapTemp(MapName)):
		Logger.logErr(["Failed to change map in SaveManager: ", MapName])
		return false
	_save_MapEdit()
	MapEdit = SQLSaveDB.get_map(MapName)
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
	Logger.LogMsg(["Saved MapTemp: ", MapTemp.MapName])
	return true

func _save_MapEdit() -> void:
	if(MapEdit != null):
		SQLSaveDB.set_map(MapEdit)

### ----------------------------------------------------
# Util
### ----------------------------------------------------

func make_new_SQLSave(SaveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, SaveName)
	return TempSave.create_new_save()

func make_new_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var NewMapTemp := MapData.get_new(MapName)
	var result := MapData.save_MapData_to_path(path, NewMapTemp)
	if(result != OK):
		Logger.logErr(["Failed to create new MapTemp, path: ", path])
		return false
	Logger.LogMsg(["Created new MapTemp: ", MapName])
	return true

func delete_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var result := FileManager.delete_file(path)
	if(result != OK):
		Logger.logErr(["Failed to delete MapTemp, path: ", path,", err: ", result])
		return false
	Logger.LogMsg(["Deleted MapTemp from path: ", path])
	return true

func delete_SQLSave(SaveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, SaveName)
	return TempSave.delete_save()
