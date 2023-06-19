### ----------------------------------------------------
# Manages save
# Usage:
# 1) Load _SaveEdit via load_SaveEdit()
# 2) Change current map via change_map()
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var TEMP_FOLDER := "res://Resources/Maps/Templates/":
	set(val):
		Logger.log_msg(["Changed SAVE_API.TEMP_FOLDER directory to: ", val])
		TEMP_FOLDER = val

var EDIT_FOLDER := "res://Resources/Maps/Saves/":
	set(val):
		Logger.log_msg(["Changed SAVE_API.EDIT_FOLDER directory to: ", val])
		EDIT_FOLDER = val

# SQLite source of _MapEdit
var _SaveEdit:SaveWriter

# SQLite source of _MapTemp
var _SaveTemp:SaveReader

# Not editable
var _MapTemp:MapData

# Editable
var _MapEdit:MapData

### ----------------------------------------------------
# API
### ----------------------------------------------------

# Sets MapTile in Data on pos
func set_on(pos:Vector3i, mapTile:MapTile) -> void:
	_MapEdit.Data[pos] = str(mapTile)

# Gets MapTile on position from Data
func get_on(pos:Vector3i) -> MapTile:
	if(_MapEdit.Data.has(pos)):
		return MapTile.new().from_string(_MapEdit.Data[pos])
	return _MapTemp.get_on(pos)

# Removes position from Data
func rem_on(pos:Vector3i) -> bool:
	return _MapEdit.rem_on(pos)

func set_terrain_on(pos:Vector3i, layerID:int, terrainID:int) -> void:
	_MapEdit.set_terrain_on(pos, layerID, terrainID)

func rem_terrain_on(pos:Vector3i, layerID:int) -> void:
	_MapEdit.rem_terrain_on(pos, layerID)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
	var MapEditChunk := _MapEdit.get_chunk(chunkPos, chunkSize)
	var MapTempChunk := _MapEdit.get_chunk(chunkPos, chunkSize)
	for pos in MapEditChunk:
		if(MapEditChunk.get(pos) == null):
			MapEditChunk[pos] = MapTempChunk.get(pos)
	return MapEditChunk

### ----------------------------------------------------
# Save Management
### ----------------------------------------------------

func load_game(saveName:String) -> bool:
	var isOk:bool = true

	var Temp := SaveWriter.new(EDIT_FOLDER, saveName)
	if(not Temp.open()):
		isOk = false
	else:
		_SaveEdit = Temp

	Logger.log_result(isOk, ["Loading game save: ", saveName])
	return isOk

func save_game(saveName:String) -> bool:
	var isOk:bool = true

	_save_MapEdit()
	if(not _SaveEdit.Save(EDIT_FOLDER + saveName + ".db")):
		isOk = false

	Logger.log_result(isOk, ["Saving game save: ", saveName])
	return isOk

func change_map(MapName:String) -> bool:
	_load_MapTemp(MapName)
	_load_MapEdit(MapName)

	Logger.log_msg(["Successfuly changed map to: ", MapName])
	return true

func _load_MapTemp(MapName:String) -> bool:
	var Temp := _SaveTemp.get_map(MapName)
	if(Temp == null):
		return false
	_MapTemp = Temp
	return true

func _save_MapEdit() -> void:
	_SaveEdit.set_map(_MapEdit)

func _load_MapEdit(MapName:String) -> bool:
	var Temp := _SaveEdit.get_map(MapName)
	if(Temp == null):
		return false
	_MapEdit = Temp
	return true

### ----------------------------------------------------
# Util
### ----------------------------------------------------

func create_new_save(folderPath:String, saveName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	return TempSave.create_new_save()

func delete_save(folderPath:String, saveName:String) -> bool:
	var TempSave := SaveWriter.new(folderPath, saveName)
	return TempSave.delete_save()
