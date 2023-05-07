### ----------------------------------------------------
### Singleton for storing game data
### Stores general data like seed for map gen, chunk size ect
### All data modules are preloaded as scripts
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

class TILEMAPS: # Stores data regardning map, TileMaps ect
	const SIM_RANGE = 1   # How far (chunks) world will generate 
	const CHUNK_SIZE = 8  # Keep it 2^x (min 8,max 32 - for both performance and drawing reasons)
	const BASE_SCALE = 16 # Pixel size of tiles
	const TILE_SIZE = Vector2i(BASE_SCALE, BASE_SCALE) # Size of a tile

class TEXTURES:
	const ENTITY_SET_PATH = "res://Resources/Textures/EntitySet.png"

class TILES:
	enum TYPES {WoodenPlank, Stone, Dirt, Grass, DarkGrass}
	const DB:Dictionary = {
		TYPES.WoodenPlank:{"Color":Color('#816109')},
		TYPES.Stone: 	  {"Color":Color('#708090')},
		TYPES.Dirt:  	  {"Color":Color('#483D8B')},
		TYPES.Grass: 	  {"Color":Color('#228B22')},
		TYPES.DarkGrass:  {"Color":Color('#006400')},
	}
