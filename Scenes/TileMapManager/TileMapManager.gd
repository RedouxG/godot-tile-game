### ----------------------------------------------------
### Manages TileMap interactions
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Keeps track of rendered chunks
var RenderedChunks:Array[Vector2i] = []

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Updates bitmask of all TileMaps
func update_all_bitmask() -> void:
	pass

# Loads a singular chunk to TileMaps
func load_chunk(chunkV3:Vector3i) -> void:
	pass

# Unloads a single chunk from TileMaps
func unload_chunk(chunkV3:Vector3i) -> void:
	pass

func refresh_tile_on(posV3:Vector3i) -> bool:
	return true

func unload_all_chunks() -> void:
	pass
