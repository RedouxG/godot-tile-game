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

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func before_all() -> void:
    randomize()

func before_each() -> void:
    FileUtils.create_dir(SAVE_FOLDER)

func after_each() -> void:
    FileUtils.delete_dir_recursive(SAVE_FOLDER)

func test_SaveWriter_save_map() -> void:
    # Given
    var saveWriter = SaveWriter.new(SAVE_FOLDER, SAVE_NAME)
    var mapData = MapData.get_new(MAP_NAME)
    var savedMapData = _fill_MapData(mapData, 1)

    # When
    var createdNewSave := saveWriter.create_new_save()
    var mapWasSet := saveWriter.set_map(mapData)
    var ableToSave := saveWriter.Save()
    var ableToClose := saveWriter.close() == OK
    var ableToOpenAfterClose := saveWriter.open()
    var recievedMap := saveWriter.get_map(MAP_NAME)

    # Then
    assert_true(createdNewSave)
    assert_true(mapWasSet)
    assert_true(ableToSave)
    assert_true(ableToClose)
    assert_true(ableToOpenAfterClose)
    assert_not_null(recievedMap)
    if(recievedMap != null):
        assert_eq(recievedMap.Data, savedMapData, "Comparing data")

func _fill_MapData(mapData:MapData, size:int) -> Dictionary:
    var result := {}
    for x in range(size): for y in range(size):
        var pos := Vector3i(x,y,0)
        var MT := MapTile.new()
        MT.set_terrain(randi(), randi())
        mapData.set_on(pos, MT)
        result[pos] = str(MT)
    return result