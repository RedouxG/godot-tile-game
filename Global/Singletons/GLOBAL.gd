### ----------------------------------------------------
### Singleton for storing game data
### Stores general data like seed for map gen, chunk size ect
### All data modules are preloaded as scripts
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

class GAME:
	const SIM_RANGE = 1   # How far (chunks) world will generate 
	const MAX_ELEVATION = 100
	const MIN_ELEVATION = -100

class TILEMAPS:
	const CHUNK_SIZE = 10
	const BASE_SCALE = 16 # Pixel size of tiles
	const TILE_SIZE = Vector2i(BASE_SCALE, BASE_SCALE) # Size of a tile

class TEXTURES:
	const ENTITY_SET_PATH = "res://Resources/Textures/EntitySet.png"

var ChunkManager := ChunkHandler.new(GAME.SIM_RANGE)

func _enter_tree() -> void:
	Logger.log_session_start()
