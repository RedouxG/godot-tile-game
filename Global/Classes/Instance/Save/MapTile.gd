### ----------------------------------------------------
### Stores data on a given tile
### ----------------------------------------------------

extends RefCounted
class_name MapTile

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var objectMapper := ObjectMapper.new(self, ["EntityData", "TerrainsData"])

# Stores data regardning an entity on this tile
var EntityData:String = ""

# {layerID: terrainID}
var TerrainsData:Dictionary = {}

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func set_terrain(layerID:int, terrainID:int) -> void:
	TerrainsData[layerID] = terrainID

func get_terrain(layerID:int) -> int:
	if(not TerrainsData.has(layerID)):
		return -1
	return TerrainsData[layerID]

func rem_terrain(layerID:int) -> bool:
	return TerrainsData.erase(layerID)

func is_empty() -> bool:
	return TerrainsData.is_empty() and EntityData.is_empty()

### ----------------------------------------------------
# ObjectMapper
### ----------------------------------------------------

func _to_string() -> String:
	return objectMapper.get_str()

func from_string(data:String) -> MapTile:
	return objectMapper.set_str(data)
