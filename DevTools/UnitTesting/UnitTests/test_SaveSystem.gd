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

func fill_MapData(MD:MapData, size:int) -> Dictionary:
	var savedData := {}
	randomize()
	for x in range(size): for y in range(size):
		var pos := Vector3(x,y,0)
		var td := Tile.new({"example":randi()}, "[]")
		MD.set_on(pos, td)
		savedData[pos] = str(td)
	return savedData

func test_MapData() -> void:
	var MD := MapData.new()
	var path := SAV_FOLDER + SAV_NAME + ".res"
	
	var SavedDict := fill_MapData(MD, 5)
	
	assert_true(
		OK == SaveManager.save_MapData_to_path(path, MD),
		"Failed to save MapData: " + path)
	
	MD = null
	
	var LMD := SaveManager.load_MapData_from_path(path)
	assert_true(LMD is MapData, "Loaded MapData is not of type MapData")
	assert_true(LMD.Data == SavedDict, "Saved dict differs from loaded")
	assert_true(LibK.Files.delete_file(path) == OK)

func test_SQLSave() -> void:
	var SQLS := SQLSave.new(SAV_FOLDER, SAV_NAME)
	assert_true(SQLS.create_new_save(), "Failed to create new save file")
	assert_true(SQLS.Load(), "Failed to load save")
	assert_true(SQLS.delete_save() == OK, "Failed to delete save file")
