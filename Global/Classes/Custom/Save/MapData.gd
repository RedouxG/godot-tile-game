### ----------------------------------------------------
# Map
### ----------------------------------------------------

extends Resource
class_name MapData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["Data", "MapName"])

@export var Data := Dictionary() # { posV3i:MapTileStr }
@export var MapName := "Default"

### ----------------------------------------------------
# API
### ----------------------------------------------------

# Sets MapTile in Data on posV3
func set_on(posV3:Vector3i, mapTile:MapTile) -> void:
	Data[posV3] = str(mapTile)

# Gets MapTile on position from Data
func get_on(posV3:Vector3i) -> MapTile:
	if(not Data.has(posV3)):
		return null
	return MapTile.new().from_str(Data[posV3])

# Removes position from Data
func rem_on(posV3:Vector3i) -> bool:
	return Data.erase(posV3)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
	var result := {}
	for posV3 in VectorTools.vec3i_get_pos_in_chunk(chunkPos, chunkSize):
		if(not Data.has(posV3)):
			result[posV3] = null
			continue
		result[posV3] = MapTile.new().from_str(Data[posV3])
	return result

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> MapData:
	Saver.set_properties_str(data)
	return self

### ----------------------------------------------------
# Static util
### ----------------------------------------------------

static func load_MapData_from_path(path:String) -> MapData:
	var TempRef = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if(not TempRef is MapData):
		return null
	return TempRef

static func save_MapData_to_path(path:String, Map:MapData) -> int:
	return ResourceSaver.save(Map, path, ResourceSaver.FLAG_COMPRESS)

static func get_new(name:String) -> MapData:
	var NewMap := MapData.new()
	NewMap.MapName = name
	return NewMap
