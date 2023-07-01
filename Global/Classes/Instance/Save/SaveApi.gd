### ----------------------------------------------------
# Serves as an API for editing given save with template
### ----------------------------------------------------

extends RefCounted
class_name SaveApi

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

# Not editable
var _TemplateMap:MapData

# Editable
var _EditableMap:MapData

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func load_map(EditableSource:SaveReader, TemplateSource:SaveReader, mapName:String) -> bool:
	var EditableMap := EditableSource.get_map(mapName)
	var TemplateMap := TemplateSource.get_map(mapName)

	if(EditableMap == null):
		Logger.log_err(["Failed to load editable map (doesn't exist): ", mapName])
		return false
	
	if(TemplateMap == null):
		Logger.log_err(["Failed to load template map (doesn't exist): ", mapName])
		return false
	
	_TemplateMap = TemplateMap
	_EditableMap = EditableMap
	return true

func save_map(EditableSource:SaveReader) -> void:
	if(_EditableMap == null):
		return
	EditableSource.set_map(_EditableMap)

# Sets MapTile in Data on pos
func set_on(pos:Vector3i, mapTile:MapTile) -> void:
	_EditableMap.Data[pos] = str(mapTile)

# Gets MapTile on position from Data
func get_on(pos:Vector3i) -> MapTile:
	if(_EditableMap.Data.has(pos)):
		return MapTile.new().from_string(_EditableMap.Data[pos])
	return _TemplateMap.get_on(pos)

# Removes position from Data
func rem_on(pos:Vector3i) -> bool:
	return _EditableMap.rem_on(pos)

func set_terrain_on(pos:Vector3i, layerID:int, terrainID:int) -> void:
	_EditableMap.set_terrain_on(pos, layerID, terrainID)

func rem_terrain_on(pos:Vector3i, layerID:int) -> void:
	_EditableMap.rem_terrain_on(pos, layerID)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
	var MapEditChunk := _EditableMap.get_chunk(chunkPos, chunkSize)
	var MapTempChunk := _EditableMap.get_chunk(chunkPos, chunkSize)
	for pos in MapEditChunk:
		if(MapEditChunk.get(pos) == null):
			MapEditChunk[pos] = MapTempChunk.get(pos)
	return MapEditChunk
