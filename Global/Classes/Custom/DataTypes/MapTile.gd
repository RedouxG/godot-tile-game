### ----------------------------------------------------
### Stores data on a given tile
### ----------------------------------------------------

extends RefCounted
class_name MapTile

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["EntityData", "TerrainData"])

# Stores data regardning an entity on this tile
var EntityData:String = ""

# {layerID: terrainID}
var TerrainData:Dictionary = {}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func set_terrain(layerID:int, terrainID:int) -> void:
	TerrainData[layerID] = terrainID

func get_terrain(layerID:int) -> int:
	if(not TerrainData.has(layerID)):
		return -1
	return TerrainData[layerID]

func rem_terrain(layerID:int) -> void:
	TerrainData.erase(layerID)

func is_empty() -> bool:
	return TerrainData.is_empty() and EntityData.is_empty()

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> MapTile:
	Saver.set_properties_str(data)
	return self
