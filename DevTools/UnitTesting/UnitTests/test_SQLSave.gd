### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _TMM = preload("res://Scenes/GameMaster//MapManager/TileMapManager/TileMapManager.tscn")
var TileMapManager:Node = null

const SAV_FOLDER := "res://Temp/"
const SAV_NAME := "UnitTest"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	TileMapManager = autoqfree(_TMM.instantiate())
	add_child(TileMapManager)

func set_MapDataCache(sqlsave:SQLSave, SavedData:Dictionary) -> void:
	var QuickTimer = STimer.new()
	for chunkPos in SavedData:
		sqlsave.MapDataCache.set_in_Data_chunk(chunkPos, SavedData[chunkPos])
	LOG_GUT(["Set time MapDataCache: ", QuickTimer.get_data()])

func get_MapDataCache(sqlsave:SQLSave, SavedData:Dictionary) -> void:
	var QuickTimer = STimer.new()
	for chunkPos in SavedData:
		var LoadedData := sqlsave.MapDataCache.get_in_Data_chunk(chunkPos)
		for posV3 in SavedData[chunkPos]:
			assert_true(SavedData[chunkPos][posV3] == LoadedData.get(posV3))
	LOG_GUT(["Get time MapDataCache: ", QuickTimer.get_data()])

func test_SQLSave_TileData():
	var sqlsave := SQLSave.new(SAV_NAME, SAV_FOLDER)
	assert_true(sqlsave.create_new_save(TileMapManager.TileMaps))
	assert_true(sqlsave.load(TileMapManager.TileMaps), "Failed to init save")
	
	var RTileMap:TileMap = TileMapManager.TileMaps[randi()%TileMapManager.TileMaps.size()]
	var RTileMapName:String = RTileMap.get_name()
	var TileIds:Array = RTileMap.tile_set.get_tiles_ids()

	# Create a block of tiles to save
	var SavedData := {}
	
	for x in range(1): for y in range(1):
		var chunkPos := Vector2(x,y)
		SavedData[chunkPos] = {} 
		for z in range(1):
			for posV3 in LibK.Vectors.vec3_get_pos_in_chunk(Vector3(x,y,z), SQLSave.SQL_CHUNK_SIZE):
				SavedData[chunkPos][posV3] = str(TileData.new({RTileMapName:TileIds[0]}))
	
	set_MapDataCache(sqlsave, SavedData)
	get_MapDataCache(sqlsave, SavedData)

	assert_true(sqlsave.save(), "Failed to save")
	assert_true(
		sqlsave.MapDataCache.Data.size() == 0,
		"MapData should be empty! Size: " + str(sqlsave.MapDataCache.Data.size()))
	sqlsave = null
	
	# Simulate trying to access data after save
	sqlsave = SQLSave.new(SAV_NAME, SAV_FOLDER)
	assert_true(sqlsave.load(TileMapManager.TileMaps), "Failed to initialize SQLSave on load")
	
	# Load all chunks from SQL
	for chunkPos in SavedData:
		sqlsave._update_SQLLoadedChunks(chunkPos)
	get_MapDataCache(sqlsave, SavedData)
	
	assert_true(SQLSave.delete_SQLDB_file(SAV_FOLDER, SAV_NAME) == OK, "Failed to delete save")

func test_SQLSave_Entity():
	var sqlsave := SQLSave.new(SAV_NAME, SAV_FOLDER, true)
	assert_true(sqlsave.create_new_save(TileMapManager.TileMaps))
	assert_true(sqlsave.load(TileMapManager.TileMaps), "Failed to init save")

	LOG_GUT(["Entity save test: "])
	var ENUM = 10 # Make sure to be in range of render
	var EntitySaved := {}
	for i in range(1,ENUM):
		var entity := GameEntity.new()
		var posV3 := Vector3(i+1,0,0)
		sqlsave.add_Entity_to_TileData(posV3, entity)
		EntitySaved[posV3] = str(entity)
		entity.free()
	
	LOG_GUT(["Entity saved data test: "])
	for posV3 in EntitySaved:
		assert_true(EntitySaved[posV3] == sqlsave.get_TileData_on(posV3).EntityData, 
			str(EntitySaved[posV3]) + "=!" + str(sqlsave.get_TileData_on(posV3).EntityData))

	assert_true(SQLSave.delete_SQLDB_file(SAV_FOLDER, SAV_NAME) == OK, "Failed to delete save")
