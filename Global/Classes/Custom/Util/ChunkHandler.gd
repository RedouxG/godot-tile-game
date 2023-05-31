### ----------------------------------------------------
### Manages chunks
### ----------------------------------------------------

extends RefCounted
class_name ChunkHandler

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var _PREC_RENDER_RANGE:Array[Vector3i]
var ChunksInRange:Array[Vector3i] = []

var _ListenerFunctions:Array[Callable] = []

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(chunkRange:int) -> void:
	_PREC_RENDER_RANGE = VectorTools.vec3i_get_range_2d(Vector3i(0,0,0), chunkRange)

func add_listener_function(function:Callable) -> void:
	_ListenerFunctions.append(function)

func update(focusPosition:Vector3) -> void:
	ChunksInRange = VectorTools.vec3i_get_precomputed_range(
		focusPosition, _PREC_RENDER_RANGE)
	for function in _ListenerFunctions:
		function.call(ChunksInRange)