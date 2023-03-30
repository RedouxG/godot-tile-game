### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTest

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SAV_FOLDER := "res://Temp/"
const SAV_NAME := "UnitTest"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


func test_MapData() -> void:
	var MD := MapData.new()
	var path := SAV_FOLDER + SAV_NAME
	assert_true(
		SaveManager.save_MapData_to_path(path, MD),
		"Failed to save MapData: " + path)
	
	var LMD := SaveManager.load_MapData_from_path(path)
	assert_true(LMD is MapData, "Loaded MapData is not of type MapData")
	
	assert_true(LibK.Files.delete_file(path) == OK)
