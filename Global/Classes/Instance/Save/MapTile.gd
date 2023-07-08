### ----------------------------------------------------
### Stores data on a given tile
### ----------------------------------------------------

extends RefCounted
class_name MapTile

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var objectMapper := ObjectMapper.new(self, ["entityData", "terrainData"])

# Stores data regardning an entity on this tile
var entityData:String = ""

# {layerID: terrainID}
var terrainData:Dictionary = {}

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func set_terrain(layerID:int, terrainID:int) -> void:
    terrainData[layerID] = terrainID

func get_terrain(layerID:int) -> int:
    if(not terrainData.has(layerID)):
        return -1
    return terrainData[layerID]

func rem_terrain(layerID:int) -> bool:
    return terrainData.erase(layerID)

func is_empty() -> bool:
    return terrainData.is_empty() and entityData.is_empty()

### ----------------------------------------------------
# ObjectMapper
### ----------------------------------------------------

func _to_string() -> String:
    return objectMapper.to_string()

func from_string(data:String) -> MapTile:
    return objectMapper.from_string(data)
