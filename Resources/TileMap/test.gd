@tool
extends EditorScript

const TM_PATH = "res://Resources/TileMap/TileMap.tscn"
const TM_SCENE = preload(TM_PATH)


func _run() -> void:
	var TS:TileSet = TM_SCENE.instantiate().tile_set
	print(TileMapTools.get_terrainNames(TS, 0))
	print(TileMapTools.get_terrainIDs(TS, 0))
