### ----------------------------------------------------
### Script auto generates TileMap
### - TM_DIR
### 	- LAYERS_DIR
### 	- TEMPLATES_DIR
### ----------------------------------------------------

@tool
extends EditorScript

### ----------------------------------------------------
### VARIABLES
### ----------------------------------------------------

enum TM_LAYERS {WallFloor, Enviroment}
enum LAYER_CONTENT {Single, Terrain}
const SET_CONTENT = ["BG.png", "Outline.png", "Template.tres"]

const TM_DIR = "res://Resources/TileMap/"
const LAYERS_DIR = TM_DIR + "Layers/"

const TM_PATH = TM_DIR + "TestTM.tscn"

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

func _run() -> void:
	if(not check_dirs()):
		push_error(["Failed check_dir()"])
		return
	if(not create_TM()):
		push_error(["Failed create_TM()"])
		return
	print("Successfully generated TileMap")

static func check_dirs() -> bool:
	var Layers := FileManager.get_dirs(LAYERS_DIR)
	for layerName in TM_LAYERS:
		if(not layerName in Layers):
			push_error(["Missing directory: ", LAYERS_DIR, layerName])
			return false
		var Modes := FileManager.get_dirs(LAYERS_DIR + layerName)
		for modeName in LAYER_CONTENT:
			if(not modeName in Modes):
				push_error(layerName + " is missing directory: " + modeName)
				return false
	return true

static func create_TM() -> bool:
	var TM := TileMap.new()
	TM.set_texture_filter(CanvasItem.TEXTURE_FILTER_NEAREST)
	TM.tile_set = get_TS()
	
	TM.remove_layer(0)
	for val in TM_LAYERS.values():
		var layerName:String = TM_LAYERS.keys()[val]
		TM.add_layer(val)
		TM.set_layer_name(val, layerName)
	
	var err := ResourceSaver.save(LibK.Scene.pack_to_scene(TM), TM_PATH)
	if(err != OK):
		push_error(["Failed to save TileMap to path: ", TM_PATH])
	return err == OK

static func get_TS() -> TileSet:
	var TS := TileSet.new()
	for layerName in FileManager.get_dirs(LAYERS_DIR):
		var Modes := FileManager.get_dirs(LAYERS_DIR + layerName)
		for modeName in Modes:
			var Sets := FileManager.get_dirs(LAYERS_DIR + layerName + '/' + modeName)
			for setName in Sets:
				_add_template(TS, LAYERS_DIR + layerName + '/' + modeName + '/' + setName)
	return TS

static func _add_template(TS:TileSet, path:String) -> void:
	var FileList := FileManager.get_files(path)
	for requiredName in SET_CONTENT:
		if(not requiredName in FileList):
			print("Skipping set: " + path + ", missing required name: " + requiredName)
			return
	pass
