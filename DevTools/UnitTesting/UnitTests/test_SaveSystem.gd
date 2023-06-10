### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends GutTest

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const SAV_FOLDER := "res://Temp/"
const SAV_NAME := "UnitTest"

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func fill_MapData(MD:MapData, size:int) -> Dictionary:
	var savedData := {}
	randomize()
	for x in range(size): for y in range(size):
		var pos := Vector3i(x,y,0)
		var MT := MapTile.new()
		MT.set_terrain(randi(), randi())
		MD.set_on(pos, MT)
		savedData[pos] = str(MT)
	return savedData

func test_MapData() -> void:
	var MD := MapData.new()
	var path := SAV_FOLDER + SAV_NAME + ".res"
	
	var SavedDict := fill_MapData(MD, 5)
	
	assert_true(
		OK == MapData.save_MapData_to_path(path, MD),
		"Failed to save MapData: " + path)
	
	MD = null
	
	var LMD := MapData.load_MapData_from_path(path)
	assert_true(LMD is MapData, "Loaded MapData is not of type MapData")
	assert_true(LMD.Data == SavedDict, "Saved dict differs from loaded")
	assert_true(FileUtils.delete_file(path) == OK)

func test_SQLSave() -> void:
	var SQLS := SQLSave.new(SAV_FOLDER, SAV_NAME)
	assert_true(SQLS.create_new_save(), "Failed to create new save file")
	assert_true(SQLS.Load(), "Failed to load save")
	
	# Simulate creating save
	var MD := MapData.new()
	MD.MapName = "Test"
	var SaveData := fill_MapData(MD,16)
	SQLS.set_map(MD)
	
	assert_true(SQLS.Save(), "Failed to save")
	assert_true(SQLS.close() == OK, "Failed to close")
	
	# Simulate loading save
	SQLS = SQLSave.new(SAV_FOLDER, SAV_NAME)
	assert_true(SQLS.Load(), "Failed to load save")
	var LoadedMD := SQLS.get_map("Test")
	assert_not_null(LoadedMD, "Loaded map is null")
	assert_true(SaveData == LoadedMD.Data, "SaveData not equal to loaded data")
	
	assert_true(SQLS.delete() == OK, "Failed to delete save file")

func test_SaveManager():
	assert_true(SAVE_MANAGER._create_new_MapTemp("Test"), "Faied to make new MapTemp")
	assert_true(SAVE_MANAGER.create_new_save("TestSave"), "Faied to make new Save")
	assert_true(SAVE_MANAGER.load_current_save("TestSave"), "Faied to load Save")
	assert_true(SAVE_MANAGER.change_map("Test"), "Failed to change map")
	
	assert_true(SAVE_MANAGER._delete_MapTemp("Test"), "Failed to delete MapTemp")
	assert_true(SAVE_MANAGER.SQLSaveDB.delete() == OK, "Failed to delete save file")
