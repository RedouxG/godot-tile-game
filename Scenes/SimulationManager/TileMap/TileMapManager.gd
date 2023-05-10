### ----------------------------------------------------
### Manages TileMap interactions
### NOTE:
### 	TerrainSetID is the same as layerID.
### 	For the game purposes these 2 are treated as one and the same
### ----------------------------------------------------

extends TileMap

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var MAX_LAYERS:int = TileMapTools.get_terrainSets_as_layers(self)
var PRE_POS_IN_CHUNK:Array[Vector3i] = VectorTools.vec3i_get_pos_in_chunk(Vector3i(0,0,0), GLOBAL.TILEMAPS.CHUNK_SIZE)

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector3i] = []

var TERRAIN_DB := TerrainDB.new()

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	if(not TERRAIN_DB.check_database_compatible(tile_set)):
		push_error("TERRAIN_DB is not compatible with TileSet! ")
		get_tree().quit()

# Loads a chunk to TileMap
func load_chunk(chunkPos:Vector3i) -> void:
	var ChunkData := SaveManager.get_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for pos in ChunkData:
		var MT:MapTile = ChunkData.get(pos)
		
		if(MT == null): continue
		for terrainSetID in MT.TerrainData:
			TileMapTools.set_terrain_cell(self,
				VectorTools.vec3i_vec2i(pos),
				terrainSetID,
				MT.get_terrain(terrainSetID))
	
	if(not RenderedChunks.has(chunkPos)):
		RenderedChunks.append(chunkPos)

# Loads a single tile to TileMap
func load_tile(pos:Vector3i) -> void:
	var MT:MapTile = SaveManager.get_on(pos)
	if(MT == null): return
	for terrainSetID in MT.TerrainData:
		TileMapTools.set_terrain_cell(self,
			VectorTools.vec3i_vec2i(pos),
			terrainSetID,
			MT.get_terrain(terrainSetID))

# Unloads a single chunk from TileMaps
func unload_chunk(chunkPos:Vector3i) -> void:
	var PosInChunk := VectorTools.vec3i_get_precomputed_pos_in_chunk(
		chunkPos, 
		PRE_POS_IN_CHUNK)
	for pos in PosInChunk:
		unload_tile(pos)
	RenderedChunks.erase(chunkPos)

func unload_tile(pos:Vector3i) -> void:
	for layer in MAX_LAYERS:
		TileMapTools.rem_terrain_cell(self, VectorTools.vec3i_vec2i(pos), layer)

func refresh_chunk(chunkPos:Vector3i) -> void:
	unload_chunk(chunkPos)
	load_chunk(chunkPos)

func refresh_all_chunks() -> void:
	for chunkPos in RenderedChunks:
		refresh_chunk(chunkPos)

func refresh_tile(pos:Vector3i) -> void:
	unload_tile(pos)
	load_tile(pos)

func unload_all() -> void:
	clear()
	RenderedChunks.clear()
