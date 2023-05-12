### ----------------------------------------------------
### Manages TileMap interactions
### ----------------------------------------------------

extends TileMap

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var PRE_POS_IN_CHUNK:Array[Vector3i] = VectorTools.vec3i_get_pos_in_chunk(Vector3i(0,0,0), GLOBAL.TILEMAPS.CHUNK_SIZE)

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector3i] = []

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Loads a chunk to TileMap
func load_chunk(chunkPos:Vector3i) -> void:
	var ChunkData := SaveManager.get_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	var PosInChunk:Array[Vector2i] = []
	for pos in ChunkData:
		var MT:MapTile = ChunkData.get(pos)
		PosInChunk.append(VectorTools.vec3i_vec2i(pos))
		if(MT == null): continue
		for layerID in MT.TerrainData:
			set_terrain_cell(
				VectorTools.vec3i_vec2i(pos),
				layerID,
				MT.get_terrain(layerID))
	
	for layerID in get_layers_count():
		BetterTerrain.update_terrain_cells(self, layerID, PosInChunk)
	
	if(not RenderedChunks.has(chunkPos)):
		RenderedChunks.append(chunkPos)

# Loads a single tile to TileMap
func load_tile(pos:Vector3i) -> void:
	var MT:MapTile = SaveManager.get_on(pos)
	if(MT == null): return
	for layerID in MT.TerrainData:
		set_terrain_cell(
			VectorTools.vec3i_vec2i(pos),
			layerID,
			MT.get_terrain(layerID))
		BetterTerrain.update_terrain_cell(self, layerID, VectorTools.vec3i_vec2i(pos))

# Unloads a single chunk from TileMaps
func unload_chunk(chunkPos:Vector3i) -> void:
	var PosInChunk := VectorTools.vec3i_get_precomputed_pos_in_chunk(chunkPos, PRE_POS_IN_CHUNK)
	for pos in PosInChunk:
		unload_tile(pos)
	RenderedChunks.erase(chunkPos)

func unload_tile(pos:Vector3i) -> void:
	for layerID in get_layers_count():
		rem_terrain_cell(VectorTools.vec3i_vec2i(pos), layerID)

func refresh_chunk(chunkPos:Vector3i) -> void:
	unload_chunk(chunkPos)
	load_chunk(chunkPos)

func refresh_all_chunks() -> void:
	for chunkPos in RenderedChunks:
		refresh_chunk(chunkPos)

func refresh_tile(pos:Vector3i) -> void:
	unload_tile(pos)
	load_tile(pos)
	for layerID in get_layers_count():
		BetterTerrain.update_terrain_cell(self, layerID, VectorTools.vec3i_vec2i(pos))

func unload_all() -> void:
	clear()
	RenderedChunks.clear()

func set_terrain_cell(pos:Vector2i, layerID:int, terrainID:int) -> void:
	BetterTerrain.set_cell(self, layerID, pos, terrainID)

func rem_terrain_cell(pos:Vector2i, layerID:int) -> void:
	erase_cell(layerID, pos)
