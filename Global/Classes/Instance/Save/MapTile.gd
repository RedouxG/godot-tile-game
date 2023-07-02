### ----------------------------------------------------
### Stores data on a given tile
### ----------------------------------------------------

extends RefCounted
class_name MapTile

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["EntityData", "TerrainsData"])

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

func rem_terrain(layerID:int) -> void:
	TerrainsData.erase(layerID)

func is_empty() -> bool:
	return TerrainsData.is_empty() and EntityData.is_empty()

### ----------------------------------------------------
# SaveManager
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> MapTile:
	Saver.set_properties_str(data)
	return self
