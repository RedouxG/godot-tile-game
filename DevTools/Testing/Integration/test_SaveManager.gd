### ----------------------------------------------------
### Integration tests for SaveManager
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
	SaveManager.TEMPLATE_FOLDER = TEMPLATE_FOLDER
	SaveManager.SAVE_FOLDER = SAVE_FOLDER

func before_each() -> void:
	FileUtils.create_dir(SAVE_FOLDER)
	FileUtils.create_dir(TEMPLATE_FOLDER)

func after_each() -> void:
	SaveManager.clear_cached_save_data()
	FileUtils.delete_dir_recursive(SAVE_FOLDER)
	FileUtils.delete_dir_recursive(TEMPLATE_FOLDER)

func test_SAVE_MANAGER_should_save_and_load_map() -> void:
	# Given
	var pos := Vector3(1,1,1)
	var mapTile := MapTile.new()
	mapTile.set_terrain(1,1)

	# When
	var createdSave := SaveManager.create_new_save(SAVE_NAME)
	var createdTemplate := SaveManager.create_new_template_save()
	var addedMapToSave := SaveManager.add_empty_map_to_save(SAVE_FOLDER, SAVE_NAME, MAP_NAME)
	var addedMapToSaveTemplate := SaveManager.add_empty_map_to_save(
		SaveManager.TEMPLATE_FOLDER, 
		SaveManager.TEMPLATE_FILE,
		MAP_NAME
	)

	var loadedGame := SaveManager.load_game(SAVE_NAME)
	var changedMap := SaveManager.change_map(MAP_NAME)

	var setMapTile := SaveManager.API.set_on(pos, mapTile)
	var savedGame := SaveManager.save_game(SAVE_NAME)
	SaveManager.clear_cached_save_data()

	var loadedGameAfterSave := SaveManager.load_game(SAVE_NAME)
	var changedMapAfterSave := SaveManager.change_map(MAP_NAME)

	# Then
	assert_true(createdSave)
	assert_true(createdTemplate)
	assert_true(addedMapToSave)
	assert_true(addedMapToSaveTemplate)
	assert_true(loadedGame)
	assert_true(changedMap)
	assert_true(setMapTile)
	assert_true(savedGame)
	assert_true(loadedGameAfterSave)
	assert_true(changedMapAfterSave)
	assert_eq(str(SaveManager.API.get_on(pos)), str(mapTile))