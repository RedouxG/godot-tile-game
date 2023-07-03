### ----------------------------------------------------
### Integration tests for save system
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SAVE_FOLDER := "res://UnitTestTemp/"
const SAVE_NAME := "UnitTest"
const MAP_NAME := "Test"

var SQLS:SaveWriter
var MD:MapData
var savedMapData:Dictionary

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func before_all() -> void:
	randomize()

func before_each() -> void:
	FileUtils.create_dir(SAVE_FOLDER)

	SQLS = SaveWriter.new(SAVE_FOLDER, SAVE_NAME)
	MD = MapData.get_new(MAP_NAME)
	savedMapData = _fill_MapData(MD, 1)

func after_each() -> void:
	FileUtils.delete_dir_recursive(SAVE_FOLDER)

func test_SaveWriter_set_map() -> void:
	var createdMap := SQLS.create_new_save()
	
	SQLS.set_map(MD)

	var SetMap := SQLS.get_map(MAP_NAME)
	assert_not_null(SetMap)
	if(SetMap != null):
		assert_eq(SetMap.Data, savedMapData, "Comparing data")

func test_SaveWriter_save() -> void:
	assert_true(SQLS.create_new_save(), "Creating new save file")
	assert_true(SQLS.Save(), "Saving")
	assert_file_exists(SAVE_FOLDER + SAVE_NAME + ".db")

func test_SaveWriter_save_map() -> void:
	assert_true(SQLS.create_new_save(), "Creating new save file")
	SQLS.set_map(MD)

	assert_true(SQLS.Save(), "Saving")
	assert_true(SQLS.close() == OK)

	assert_true(SQLS.open())
	var SetMap := SQLS.get_map(MAP_NAME)
	assert_not_null(SetMap)
	if(SetMap != null):
		assert_eq(SetMap.Data, savedMapData, "Comparing data")

func _fill_MapData(mapData:MapData, size:int) -> Dictionary:
	var result := {}
	for x in range(size): for y in range(size):
		var pos := Vector3i(x,y,0)
		var MT := MapTile.new()
		MT.set_terrain(randi(), randi())
		mapData.set_on(pos, MT)
		result[pos] = str(MT)
	return result