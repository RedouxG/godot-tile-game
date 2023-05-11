### ----------------------------------------------------
### Stores information about a single terrain
### ----------------------------------------------------

extends RefCounted
class_name TerrainData

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["layerID","description"])

# Description shown when inspecting a tile of a given terrain
var layerID:int
var description:String = "Not setup"

func _init(layer:int) -> void:
	layerID = layer

func set_description(desc:String) -> TerrainData:
	description = desc
	return self

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> TerrainData:
	Saver.set_properties_str(data)
	return self
