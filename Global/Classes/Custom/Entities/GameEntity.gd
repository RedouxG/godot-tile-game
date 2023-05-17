### ----------------------------------------------------
### Base class of all in game entities
### ----------------------------------------------------

extends Sprite2D
class_name GameEntity

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["MapPosition"])

# Position on the game map
var MapPosition := Vector3i(0,0,0): set = _set_MapPosition
func _set_MapPosition(posV3:Vector3i):
	global_position = VectorTools.vec3i_vec2i(posV3)
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
	texture = ImageTools.get_sprite_from_texture(spritePos, GLOBAL.TILEMAPS.TILE_SIZE, setTexture)
	offset = GLOBAL.TILEMAPS.TILE_SIZE/2

# Unloads itself into TileData and queue_free()
func unload_entity(unloadedChunkV3:Vector3i) -> void:
	if(not unloadedChunkV3 == VectorTools.scale_down_vec3i_noZ(MapPosition, GLOBAL.TILEMAPS.CHUNK_SIZE)): 
		return
	if(not save_entity()):
		Logger.log_err(["Failed to save entity data on unload, pos: ", MapPosition])
	queue_free()

# Saves this entity
func save_entity() -> bool:
	return SaveManager.add_Entity_to_TileData(MapPosition, self)
	
### ----------------------------------------------------
# Utils
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> GameEntity:
	Saver.set_properties_str(data)
	return self
