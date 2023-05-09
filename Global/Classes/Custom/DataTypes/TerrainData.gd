### ----------------------------------------------------
### Stores information about a single terrain
### ----------------------------------------------------

extends RefCounted
class_name TerrainData

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["metadata"])

# Description shown when inspecting a tile of a given terrain
var Description:String = "Not setup"

func set_description(desc:String) -> TerrainData:
	Description = desc
	return self

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> TerrainData:
	Saver.set_properties_str(data)
	return self
