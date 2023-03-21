### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SAVE_NAME = "UnitTest"
const _MM = preload("res://Scenes/GameMaster/MapManager/MapManager.tscn")
var MapManager:Node = null

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	MapManager = autofree(_MM.instantiate())
	add_child(MapManager)
	var TileMaps:Array = $MapManager/TileMapManager.TileMaps
	if(not SaveManager.create_empty_save(SAVE_NAME, SaveManager.MAP_FOLDER, TileMaps)):
		push_error("Failed to init unit test")
		get_tree().quit()
	if(not SaveManager.create_empty_save(SAVE_NAME, SaveManager.SAV_FOLDER, TileMaps)):
		push_error("Failed to init unit test")
		get_tree().quit()
	assert_true(MapManager.start_simulation(SAVE_NAME, SAVE_NAME), "Failed to start simulation")

func after_each():
	assert_true(SaveManager.delete_sav(SAVE_NAME) == OK, "Failed to delete save: " + SAVE_NAME)
	assert_true(SaveManager._delete_map(SAVE_NAME) == OK, "Failed to delete map: " + SAVE_NAME)
	assert_true(SaveManager.clean_TEMP(), "Failed to clean TEMP")
	print_orphan_nodes()

func test_MapManager():
	assert_true(MapManager.LoadedChunks.size() == pow(MapManager.SIM_RANGE*2+1, 2),
				"LoadedChunks size doesnt match: "+ str(pow(MapManager.SIM_RANGE*2+1, 2)) +" =! "+ str(MapManager.LoadedChunks.size()))
	assert_true(MapManager.GameFocusEntity is PlayerEntity, "GameFocusEntity is not PlayerEntity")
	assert_true(MapManager.SimulatedEntities.size() == 1)

func test_EntityManager():
	var ENUM = 10 # Make sure to be in range of render
	for i in range(1,ENUM):
		var entity := GameEntity.new()
		SaveManager.add_Entity_to_TileData(Vector3(i+1,0,0), entity)
		entity.free()
	
	MapManager.update_simulation(true)
	
	assert_true($MapManager/EntityManager.get_child_count() == ENUM, "Entity count should be equal to expected")
	LOG_GUT(["Enity count: ", $MapManager/EntityManager.get_child_count(), ", expected: ", ENUM])
