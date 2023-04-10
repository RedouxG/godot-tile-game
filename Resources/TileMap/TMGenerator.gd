@tool
extends EditorScript

const TM_DIRC = "res://Resources/TileMap/"
const TM_DEST = TM_DIRC + "TestTM.tscn"

enum TM_LAYERS {WallFloor, Enviroment}

func _run() -> void:
	create_TM()


func create_TM() -> bool:
	var TM := TileMap.new()
	TM.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	
	TM.remove_layer(0)
	for val in TM_LAYERS.values():
		var layerName:String = TM_LAYERS.keys()[val]
		TM.add_layer(val)
		TM.set_layer_name(val, layerName)
	
	var err := ResourceSaver.save(LibK.Scene.pack_to_scene(TM), TM_DEST)
	if(err != OK):
		Logger.logErr(["Failed to save TileMap to path: ", TM_DEST])
	return err == OK
