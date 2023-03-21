### ----------------------------------------------------
### Base class of all in game entities
### ----------------------------------------------------

extends Sprite2D
class_name GameEntity

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# List of property names that are meant to be saved
const PROPERTY_TO_SAVE = ["MapPosition"]

# Position on the game map
var MapPosition := Vector3i(0,0,0): set = _set_MapPosition
func _set_MapPosition(posV3:Vector3i):
	global_position = LibK.Vectors.vec3i_vec2i(posV3)
	MapPosition = posV3

# Position of the sprite on texture set
var TexturePos := Vector2i(0,0)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	_on_entity_ready()

# Function called on ready (to overwrite if needed)
func _on_entity_ready() -> void:
	set_sprite(TexturePos, GLOBAL.TEXTURES.ENTITY_SET_PATH)

# Loads sprite from sprite set
func set_sprite(spritePos:Vector2i, texturePath:String) -> void:
	var setTexture:Texture2D = ResourceLoader.load(texturePath, "Texture2D")
	texture = LibK.Img.get_sprite_from_texture(spritePos, GLOBAL.TILEMAPS.TILE_SIZE, setTexture)
	offset = GLOBAL.TILEMAPS.TILE_SIZE/2

# Unloads itself into TileData and queue_free()
func unload_entity(unloadedChunkV3:Vector3i) -> void:
	if(not unloadedChunkV3 == LibK.Vectors.scale_down_vec3(MapPosition, GLOBAL.TILEMAPS.CHUNK_SIZE)): 
		return
	if(not save_entity()):
		Logger.logErr(["Failed to save entity data on unload, pos: ", MapPosition],get_stack())
	queue_free()

# Saves this entity
func save_entity() -> bool:
	return SaveManager.add_Entity_to_TileData(MapPosition, self)
	
### ----------------------------------------------------
# Utils
### ----------------------------------------------------

# Creates a copy of entity from its data string
func from_str(s:String):
	return from_array(str_to_var(s))

# Creates copy of entity data as string
func _to_string() -> String:
	return var_to_str(to_array())

# Converts entity data to an array
func to_array() -> Array[String]:
	var arr:Array[String] = []
	for propertyName in PROPERTY_TO_SAVE:
		arr.append(get(propertyName))
	return arr

# Creates copy of entity data as Array
func from_array(arr:Array):
	var index := 0
	for propertyName in PROPERTY_TO_SAVE:
		set(propertyName, arr[index])
		index+=1
	return self
