### ----------------------------------------------------
# Automatic TileSet generation
### ----------------------------------------------------

@tool
extends EditorScript

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SETS_PATH = "res://Scenes/TileMap/SpriteSets/"
const BG_IMAGE_NAME =  "BG.png"
const OUTLINE_IMAGE_NAME = "Outline.png"

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func generate_set_image(path:String) -> Image:
	var BGImage := ImageTools.load_image(path + BG_IMAGE_NAME)
	var OutlineImage := ImageTools.load_image(path + OUTLINE_IMAGE_NAME)
	if(BGImage == null or OutlineImage == null):
		return null
	
	return ImageTools.stack_images(BGImage, OutlineImage, Color.RED, 0.5)

func _run() -> void:
	#var image := generate_set_image(SETS_PATH + "Background/Walls/")
	#if(image != null):
	#	image.save_png("res://Temp/test.png")
	pass
