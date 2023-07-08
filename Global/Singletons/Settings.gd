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

class MAP:
    const TILE_PIXEL_SIZE = 16
    const TILE_PIXEL_SIZE_VECTOR = Vector2i(TILE_PIXEL_SIZE, TILE_PIXEL_SIZE)

    const CHUNK_SIZE = 10
    const CHUNK_PIXEL_SIZE = CHUNK_SIZE * TILE_PIXEL_SIZE
    const CHUNK_PIXEL_SIZE_VECTOR = Vector2i(CHUNK_PIXEL_SIZE, CHUNK_PIXEL_SIZE)

class TEXTURES:
    const ENTITY_SET_PATH = "res://Resources/Textures/EntitySet.png"

var ChunkManager := ChunkHandler.new(GAME.SIM_RANGE)
