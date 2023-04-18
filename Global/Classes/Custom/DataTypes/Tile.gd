### ----------------------------------------------------
### Stores data on a given tile
### ----------------------------------------------------

extends RefCounted
class_name MapTile

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["EntityData", "layer", "terrain", "terrainSet"])

# Stores data regardning an entity on this tile
var EntityData:String = ""

var layer:int = -1
var terrain:int = -1
var terrainSet:int = -1

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> MapTile:
	Saver.set_properties_str(data)
	return self
