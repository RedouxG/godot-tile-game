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

# Loops through file system and checks for any errors
func get_file_system() -> Dictionary:
	var FileSystem:Dictionary = FileManager.get_dir_system_recursive(SETS_PATH)
	for fileData in FileSystem:
		if(not fileData.isDir): continue
		
		var LayerDir:Dictionary = FileSystem[fileData]
		for cellData in LayerDir:
			if(not cellData.isDir): continue
			
			var cellImagesDir:Dictionary = LayerDir[cellData]
			
			var imageNames:Array[String] = []
			for imageData in cellImagesDir:
				imageNames.append(imageData.name)
			
			if(not imageNames.has(BG_IMAGE_NAME)):
				print_debug("Directory missing image: ", BG_IMAGE_NAME,", ", cellData.fullPath)
			elif(not imageNames.has(OUTLINE_IMAGE_NAME)):
				print_debug("Directory missing image: ", OUTLINE_IMAGE_NAME,", ", cellData.fullPath)
			else:
				print_debug("Cell data for directory is correct: ", cellData.fullPath)
	return FileSystem

func generate_set_image(path:String) -> Image:
	var BGImage := ImageTools.load_image(path + BG_IMAGE_NAME)
	var OutlineImage := ImageTools.load_image(path + OUTLINE_IMAGE_NAME)
	if(BGImage == null or OutlineImage == null):
		return null
	
	return ImageTools.stack_images(BGImage, OutlineImage, Color.RED, 0.5)

func _run() -> void:
	get_file_system()
	pass
