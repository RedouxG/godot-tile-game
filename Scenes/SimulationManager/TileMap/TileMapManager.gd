### ----------------------------------------------------
### Manages TileMap interactions
### ----------------------------------------------------

extends TileMap

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var PRE_POS_IN_CHUNK3:Array[Vector3i] = VectorUtils.vec3i_get_pos_in_chunk(Vector3i(0,0,0), GLOBAL.TILEMAPS.CHUNK_SIZE)
var PRE_POS_IN_CHUNK2:Array[Vector2i] = VectorUtils.vec2i_get_pos_in_chunk(Vector2i(0,0), GLOBAL.TILEMAPS.CHUNK_SIZE)

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector3i] = []

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func update(ChunksToRender:Array[Vector3i]) -> void:
	# Loading chunks that are not yet rendered
	for chunkPos in ChunksToRender:
		if(RenderedChunks.has(chunkPos)): continue
		load_chunk(chunkPos)
	
	# Unload old chunks that are not meant to be seen
	for i in range(RenderedChunks.size() - 1, -1, -1):
		if(ChunksToRender.has(RenderedChunks[i])): continue
		unload_chunk(RenderedChunks[i])

# Loads a chunk to TileMap
func load_chunk(chunkPos:Vector3i) -> void:
	var ChunkData := SaveManager.get_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for pos in ChunkData:
		var MT:MapTile = ChunkData.get(pos)
		if(MT == null): continue
		for layerID in MT.TerrainsData:
			BetterTerrain.set_cell(self, layerID, VectorUtils.vec3i_vec2i(pos), MT.get_terrain(layerID))
	
	_update_tiles_bitmask(
		VectorUtils.vec2i_get_precomputed_pos_in_chunk(
			VectorUtils.vec3i_vec2i(chunkPos), PRE_POS_IN_CHUNK2))

	if(not RenderedChunks.has(chunkPos)):
		RenderedChunks.append(chunkPos)

# Loads a single tile to TileMap
func load_tile(pos:Vector3i) -> void:
	var MT:MapTile = SaveManager.get_on(pos)
	if(MT == null): return
	for layerID in MT.TerrainsData:
		BetterTerrain.set_cell(self, layerID, VectorUtils.vec3i_vec2i(pos), MT.get_terrain(layerID))
		BetterTerrain.update_terrain_cell(self, layerID, VectorUtils.vec3i_vec2i(pos))

# Unloads a single chunk from TileMaps
func unload_chunk(chunkPos:Vector3i) -> void:
	var PosInChunk := VectorUtils.vec3i_get_precomputed_pos_in_chunk(chunkPos, PRE_POS_IN_CHUNK3)
	for pos in PosInChunk:
		unload_tile(pos)
	RenderedChunks.erase(chunkPos)

func unload_tile(pos:Vector3i) -> void:
	for layerID in get_layers_count():
		erase_cell(layerID, VectorUtils.vec3i_vec2i(pos))

func refresh_chunk(chunkPos:Vector3i) -> void:
	unload_chunk(chunkPos)
	load_chunk(chunkPos)

func refresh_all_chunks() -> void:
	for chunkPos in RenderedChunks:
		refresh_chunk(chunkPos)

func refresh_tile(pos:Vector3i) -> void:
	unload_tile(pos)
	load_tile(pos)
	_update_tiles_bitmask([VectorUtils.vec3i_vec2i(pos)])

func unload_all() -> void:
	clear()
	RenderedChunks.clear()

func _update_tiles_bitmask(positions:Array[Vector2i]) -> void:
	for layerID in get_layers_count():
		BetterTerrain.update_terrain_cells(self, layerID, positions)