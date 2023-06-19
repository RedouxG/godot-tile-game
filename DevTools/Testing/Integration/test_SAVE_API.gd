### ----------------------------------------------------
### Integration tests for SAVE_API
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const EDIT_FOLDER := "res://UnitTestTemp1/"
const TEMP_FOLDER := "res://UnitTestTemp2/"
const SAVE_NAME := "UnitTest"
const MAP_NAME := "Test"

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func before_all() -> void:
	SAVE_API.TEMP_FOLDER = TEMP_FOLDER
	SAVE_API.EDIT_FOLDER = EDIT_FOLDER

func before_each() -> void:
	FileUtils.create_dir(EDIT_FOLDER)
	FileUtils.create_dir(TEMP_FOLDER)

func after_each() -> void:
	SAVE_API._SaveEdit = null
	SAVE_API._SaveTemp = null
	SAVE_API._MapTemp = null
	SAVE_API._MapEdit = null
	FileUtils.delete_dir_recursive(EDIT_FOLDER)
	FileUtils.delete_dir_recursive(TEMP_FOLDER)

func test_SaveManager():
	pass