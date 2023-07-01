### ----------------------------------------------------
### Base class of all in game entities
### ----------------------------------------------------

extends Sprite2D
class_name GameEntity

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["MapPosition"])

# Position on the game map
var MapPosition := Vector3i(0,0,0): set = _set_MapPosition
func _set_MapPosition(posV3:Vector3i):
	global_position = VectorUtilsExt.vec3i_vec2i(posV3)
	MapPosition = posV3

# Position of the sprite on texture set
var TexturePos := Vector2i(0,0)

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _ready() -> void:
	_on_entity_ready()

# Function called on ready (to overwrite if needed)
func _on_entity_ready() -> void:
	set_sprite(TexturePos, GLOBAL.TEXTURES.ENTITY_SET_PATH)

# Loads sprite from sprite set
func set_sprite(spritePos:Vector2i, texturePath:String) -> void:
	var setTexture:Texture2D = ResourceLoader.load(texturePath, "Texture2D")
	texture = ImageUtils.get_sprite_from_texture(
		spritePos, 
		GLOBAL.MAP.TILE_PIXEL_SIZE_VECTOR, 
		setTexture
	)
	offset = GLOBAL.MAP.TILE_PIXEL_SIZE_VECTOR/2

func unload_entity() -> void:
	if(not save_entity()):
		Logger.log_err(["Failed to save entity data on unload, pos: ", MapPosition])
	queue_free()

# Saves this entity
func save_entity() -> bool:
	return SAVE_MANAGER.add_Entity_to_TileData(MapPosition, self)
	
### ----------------------------------------------------
# Utils
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> GameEntity:
	Saver.set_properties_str(data)
	return self
