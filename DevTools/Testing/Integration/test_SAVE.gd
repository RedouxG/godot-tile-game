### ----------------------------------------------------
### Integration tests for SAVE
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SAVE_FOLDER := "res://UnitTestTemp1/"
const TEMPLATE_FOLDER := "res://UnitTestTemp2/"
const SAVE_NAME := "UnitTest"
const MAP_NAME := "Test"

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func before_all() -> void:
	SAVE.TEMPLATE_FOLDER = TEMPLATE_FOLDER
	SAVE.SAVE_FOLDER = SAVE_FOLDER

func before_each() -> void:
	FileUtils.create_dir(SAVE_FOLDER)
	FileUtils.create_dir(TEMPLATE_FOLDER)

func after_each() -> void:
	SAVE._EditableSave = null
	SAVE._TemplateSave = null
	SAVE.API._TemplateMap = null
	SAVE.API._EditableMap = null
	FileUtils.delete_dir_recursive(SAVE_FOLDER)
	FileUtils.delete_dir_recursive(TEMPLATE_FOLDER)

func test_SAVE_should_save_and_load_game() -> void:
	assert_true(SAVE.create_new_save(TEMPLATE_FOLDER, SAVE_NAME))
	assert_true(SAVE.create_new_save(SAVE_FOLDER, SAVE_NAME))
	assert_true(SAVE.load_game(SAVE_NAME))
	assert_true(SAVE.save_game(SAVE_NAME))
