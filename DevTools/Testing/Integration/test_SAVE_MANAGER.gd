### ----------------------------------------------------
### Integration tests for SAVE_MANAGER
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
	SAVE_MANAGER.TEMPLATE_FOLDER = TEMPLATE_FOLDER
	SAVE_MANAGER.SAVE_FOLDER = SAVE_FOLDER

func before_each() -> void:
	FileUtils.create_dir(SAVE_FOLDER)
	FileUtils.create_dir(TEMPLATE_FOLDER)

func after_each() -> void:
	SAVE_MANAGER.clear_cached_save_data()
	FileUtils.delete_dir_recursive(SAVE_FOLDER)
	FileUtils.delete_dir_recursive(TEMPLATE_FOLDER)

func test_SAVE_MANAGER_should_save_and_load_map() -> void:
	# Given
	var pos := Vector3(1,1,1)
	var mapTile := MapTile.new()
	mapTile.set_terrain(1,1)

	# When
	var createdSave := SAVE_MANAGER.create_new_save(SAVE_NAME)
	var createdTemplate := SAVE_MANAGER.create_new_template_save()
	var addedMapToSave := SAVE_MANAGER.add_empty_map_to_save(SAVE_FOLDER, SAVE_NAME, MAP_NAME)
	var addedMapToSaveTemplate := SAVE_MANAGER.add_empty_map_to_save(
		SAVE_MANAGER.TEMPLATE_FOLDER, 
		SAVE_MANAGER.TEMPLATE_FILE,
		MAP_NAME
	)

	var loadedGame := SAVE_MANAGER.load_game(SAVE_NAME)
	var changedMap := SAVE_MANAGER.change_map(MAP_NAME)

	if(changedMap):
		SAVE_MANAGER.API.set_on(pos, mapTile)
	
	var savedGame := SAVE_MANAGER.save_game(SAVE_NAME)
	SAVE_MANAGER.clear_cached_save_data()

	var loadedGameAfterSave := SAVE_MANAGER.load_game(SAVE_NAME)
	var changedMapAfterSave := SAVE_MANAGER.change_map(MAP_NAME)

	# Then
	assert_true(createdSave)
	assert_true(createdTemplate)
	assert_true(addedMapToSave)
	assert_true(addedMapToSaveTemplate)
	assert_true(loadedGame)
	assert_true(changedMap)
	assert_true(savedGame)
	assert_true(loadedGameAfterSave)
	assert_true(changedMapAfterSave)
	if(changedMapAfterSave):
		assert_eq(SAVE_MANAGER.API.get_on(pos)._to_string(), mapTile.to_string())