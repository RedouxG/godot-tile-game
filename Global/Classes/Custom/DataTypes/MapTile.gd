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

# {TerrainSetID: terrainID}
var TerrainData:Dictionary = {}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func set_terrain(terrainSetID:int, terrainID:int) -> void:
	TerrainData[terrainSetID] = terrainID

func get_terrain(terrainSetID:int) -> int:
	if(not TerrainData.has(terrainSetID)):
		return -1
	return TerrainData[terrainSetID]

func rem_terrain(terrainSetID:int) -> void:
	TerrainData.erase(terrainSetID)

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
