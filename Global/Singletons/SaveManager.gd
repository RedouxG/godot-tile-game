### ----------------------------------------------------
# Manages save
# Usage:
# 1) Load SQLSaveDB via load_SQLSaveDB()
# 2) Change current map via change_map()
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

# Sets MapTile in Data on pos
func set_on(pos:Vector3i, mapTile:MapTile) -> void:
	MapEdit.Data[pos] = str(mapTile)

# Gets MapTile on position from Data
func get_on(pos:Vector3i) -> MapTile:
	if(MapEdit.Data.has(pos)):
		return MapTile.new().from_string(MapEdit.Data[pos])
	return MapTemp.get_on(pos)

# Removes position from Data
func rem_on(pos:Vector3i) -> bool:
	return MapEdit.rem_on(pos)

func set_terrain_on(pos:Vector3i, layerID:int, terrainID:int) -> void:
	MapEdit.set_terrain_on(pos, layerID, terrainID)

func rem_terrain_on(pos:Vector3i, layerID:int) -> void:
	MapEdit.rem_terrain_on(pos, layerID)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
	var MapEditChunk := MapEdit.get_chunk(chunkPos, chunkSize)
	var MapTempChunk := MapEdit.get_chunk(chunkPos, chunkSize)
	for pos in MapEditChunk:
		if(MapEditChunk.get(pos) == null):
			MapEditChunk[pos] = MapTempChunk.get(pos)
	return MapEditChunk

### ----------------------------------------------------
# Save Management
### ----------------------------------------------------

func load_current_save(saveName:String) -> bool:
	var result := _load_SQLSave(saveName)
	if(result == true):  Logger.log_msg(["Successfuly changed the save to: ", saveName])
	if(result == false): Logger.log_err(["Failed to changed the save to: ", saveName])
	return result

func save_current_save(saveName:String) -> bool:
	var result := _save_SQLSave(saveName)
	if(result == true):  Logger.log_msg(["Successfuly saved: ", saveName])
	if(result == false): Logger.log_err(["Failed to save: ", saveName])
	return result

func change_map(MapName:String) -> bool:
	if(not _load_MapTemp(MapName)):
		Logger.log_err(["Failed to change map to: ", MapName])
		return false
	_load_MapEdit(MapName)
	Logger.log_msg(["Successfuly changed map to: ", MapName])
	return true

func _load_SQLSave(saveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, saveName)
	if(not TempSave.Load()):
		Logger.log_err(["Failed to load game save: ", saveName])
		return false
	if(SQLSaveDB != null):
		SQLSaveDB.close()
	SQLSaveDB = TempSave
	Logger.log_msg(["Loaded game save: ", saveName])
	return true

func _save_SQLSave(saveName:String) -> bool:
	_save_MapEdit()
	if(not SQLSaveDB.Save(EDIT_FOLDER + saveName + ".db")):
		Logger.log_err(["Failed to save game save: ", SQLSaveDB.SQL_DB_DEST.path])
		return false
	Logger.log_msg(["Saved game save: ", saveName])
	return true

func _load_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var TempResult := MapData.load_MapData_from_path(path)
	if(TempResult == null):
		Logger.log_err(["Failed to load MapTemp from path: ", path])
		return false
	MapTemp = TempResult
	Logger.log_msg(["Loaded MapTemp: ", MapName])
	return true

func _save_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapTemp.MapName + ".res"
	var result := MapData.save_MapData_to_path(path, MapTemp)
	if(result != OK):
		Logger.log_err(["Failed to save MapTemp to path: ", path])
		return false
	Logger.log_msg(["Saved MapTemp: ", MapTemp.MapName])
	return true

func _save_MapEdit() -> void:
	if(MapEdit != null):
		SQLSaveDB.set_map(MapEdit)
	Logger.log_msg(["Saved MapEdit: ", MapEdit.MapName])

func _load_MapEdit(MapName:String) -> void:
	MapEdit = SQLSaveDB.get_map(MapName)
	Logger.log_msg(["Loaded MapEdit: ", MapEdit.MapName])

### ----------------------------------------------------
# Util
### ----------------------------------------------------

func create_new_save(saveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, saveName)
	return TempSave.create_new_save()

func delete_save(saveName:String) -> bool:
	var TempSave := SQLSave.new(EDIT_FOLDER, saveName)
	return TempSave.delete_save()

func _create_new_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var NewMapTemp := MapData.get_new(MapName)
	var result := MapData.save_MapData_to_path(path, NewMapTemp)
	if(result != OK):
		Logger.log_err(["Failed to create new MapTemp, path: ", path])
		return false
	Logger.log_msg(["Created new MapTemp: ", MapName])
	return true

func _delete_MapTemp(MapName:String) -> bool:
	var path := TEMP_FOLDER + MapName + ".res"
	var result := FileTools.delete_file(path)
	if(result != OK):
		Logger.log_err(["Failed to delete MapTemp, path: ", path,", err: ", result])
		return false
	Logger.log_msg(["Deleted MapTemp from path: ", path])
	return true
