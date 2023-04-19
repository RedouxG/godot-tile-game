### ----------------------------------------------------
### Manages TileMap interactions
### ----------------------------------------------------

extends TileMap

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector2i] = []

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Loads a singular chunk to TileMaps
func load_chunk(chunkPos:Vector3i) -> void:
	var ChunkData := SaveManager.get_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for pos in ChunkData:
		var MT:MapTile = ChunkData.get(pos)
		
		if(MT == null): continue
		set_cells_terrain_connect(MT.layer, [VectorTools.vec3i_vec2i(pos)], MT.terrain_set, MT.terrain)
	
	if(not RenderedChunks.has(VectorTools.vec3i_vec2i(chunkPos))):
		RenderedChunks.append(VectorTools.vec3i_vec2i(chunkPos))

# Unloads a single chunk from TileMaps
func unload_chunk(chunkPos:Vector3i) -> void:
	var PosInChunk = VectorTools.vec3i_get_pos_in_chunk(chunkPos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	for layer in get_layers_count():
		for pos in PosInChunk:
			erase_cell(layer, VectorTools.vec3i_vec2i(pos))
	RenderedChunks.erase(VectorTools.vec3i_vec2i(chunkPos))

func refresh_chunk(chunkPos:Vector3i) -> void:
	unload_chunk(chunkPos)
	load_chunk(chunkPos)

func refresh_tile(pos:Vector2i) -> void:
	for layer in get_layers_count():
		erase_cell(layer, pos)

func unload_all() -> void:
	clear()
	RenderedChunks.clear()
