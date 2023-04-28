### ----------------------------------------------------
### Manages TileMap interactions
### ----------------------------------------------------

extends TileMap

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector3i] = []

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Loads a chunk to TileMap
func load_chunk(chunkPos:Vector3i) -> void:
	var ChunkData := SaveManager.get_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for pos in ChunkData:
		var MT:MapTile = ChunkData.get(pos)
		
		if(MT == null): continue
		for terrainSetID in MT.TerrainData:
			set_cells_terrain_connect(
				terrainSetID, 
				[VectorTools.vec3i_vec2i(pos)], 
				terrainSetID, 
				MT.get_terrain(terrainSetID))
	
	if(not RenderedChunks.has(chunkPos)):
		RenderedChunks.append(chunkPos)

# Loads a single tile to TileMap
func load_tile(pos:Vector3i) -> void:
	var MT:MapTile = SaveManager.get_on(pos)
	if(MT == null): return
	for terrainSetID in MT.TerrainData:
		set_cells_terrain_connect(
			terrainSetID, 
			[VectorTools.vec3i_vec2i(pos)], 
			terrainSetID, 
			MT.get_terrain(terrainSetID))

# Unloads a single chunk from TileMaps
func unload_chunk(chunkPos:Vector3i) -> void:
	var PosInChunk := VectorTools.vec3i_get_pos_in_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for pos in PosInChunk:
		unload_tile(pos)
	RenderedChunks.erase(chunkPos)

func unload_tile(pos:Vector3i) -> void:
	for layer in get_layers_count():
		erase_cell(layer, VectorTools.vec3i_vec2i(pos))

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
