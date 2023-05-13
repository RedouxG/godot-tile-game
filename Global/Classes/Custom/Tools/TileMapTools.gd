### ----------------------------------------------------
### Wrapper around godot built in TileSet
### ----------------------------------------------------

extends Node
class_name TileMapTools

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func get_layers(TM:TileMap) -> Array[int]:
	var output:Array[int] = []
	for i in TM.get_layers_count():
		output.append(i)
	return output
