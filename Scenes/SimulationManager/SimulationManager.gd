### ----------------------------------------------------
# Manages whole simulation, decides what to render
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

@onready var TM:TileMap = $TileMapManager
@onready var PREC_RENDER_RANGE := VectorTools.vec3i_get_range_2d(Vector3i(0,0,0), GLOBAL.SIMULATION.SIM_RANGE)

var GameFocusEntity:GameEntity

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func start() -> bool:
	return true

# Updates the simulation 
func update_render() -> void:
	var chunksToRender := VectorTools.vec3i_get_precomputed_range(
		GameFocusEntity.MapPosition,
		PREC_RENDER_RANGE)

	# Loading chunks that are not yet rendered
	for chunkPos in chunksToRender:
		if(TM.RenderedChunks.has(chunkPos)): continue
		TM.load_chunk(chunkPos)
	
	# Unload old chunks that are not meant to be seen
	for i in range(TM.RenderedChunks.size() - 1, -1, -1):
		var chunkPos:Vector3i = TM.RenderedChunks[i]
		if(chunksToRender.has(chunkPos)): continue
		TM.unload_chunk(chunkPos)
