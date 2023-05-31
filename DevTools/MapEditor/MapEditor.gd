### ----------------------------------------------------
### Input management for MapEditor
### Key inputs:
### 	Q and E - Switch layer
### 	Z and X - Switch tile
### 	Alt     - Load current map
### 	Ctrl    - Save current map
### 	F       - Add filter to listed tiles
### ----------------------------------------------------

extends DrawNode

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const EDITOR_SAVE_NAME := "EDITOR"
const CHUNK_PIXEL_SIZE = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
const CHUNK_SIZE_VECTOR = Vector2i(CHUNK_PIXEL_SIZE, CHUNK_PIXEL_SIZE)

const TILE_STATE = preload("res://DevTools/MapEditor/States/TileState.gd")
const FLTR_STATE = preload("res://DevTools/MapEditor/States/FltrState.gd")
const SAVE_STATE = preload("res://DevTools/MapEditor/States/SaveState.gd")
const LOAD_STATE = preload("res://DevTools/MapEditor/States/LoadState.gd")
const GOTO_STATE = preload("res://DevTools/MapEditor/States/GotoState.gd")

@onready var UIElement := {
	UIRoot =         $UIElements/MC,
	
	SelectionUI =    $UIElements/MC/GC/SelectionUI,
	TerrainSelect =  $UIElements/MC/GC/SelectionUI/TerrainSelect,
	TileItemList =   $UIElements/MC/GC/SelectionUI/ItemList,
	
	SaveInput =      $UIElements/MC/GC/Info/SaveInput,
	LoadInput =      $UIElements/MC/GC/Info/LoadInput,
	GotoInput =      $UIElements/MC/GC/Info/GotoInput,
	FilterInput =    $UIElements/MC/GC/Info/FilterInput,
	
	CellText =       $UIElements/MC/GC/Info/CellText,
	FilterText =     $UIElements/MC/GC/Info/FilterInput,
	ChunkText =      $UIElements/MC/GC/Info/ChunkText,
	ElevationText =  $UIElements/MC/GC/Info/ElevationText,
	DrawModeText =   $UIElements/MC/GC/Info/DrawMode,
}

@onready var TM:TileMap = $TileMapManager
@onready var TS:TileSet = $TileMapManager.tile_set

var EditorStateMachine := StateMachine.new()
@onready var TileState := TILE_STATE.new(self, "TILE_STATE")
@onready var FilterState := FLTR_STATE.new(self, "FLTR_STATE")
@onready var SaveState := SAVE_STATE.new(self, "SAVE_STATE")
@onready var LoadState := LOAD_STATE.new(self, "LOAD_STATE")
@onready var GoToState := GOTO_STATE.new(self, "GOTO_STATE")

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	GLOBAL.ChunkManager.add_listener_function(Callable(TM, "update"))
	
	var isOK := true
	EditorStateMachine.add_state(TileState)
	EditorStateMachine.add_state(FilterState)
	EditorStateMachine.add_state(SaveState)
	EditorStateMachine.add_state(LoadState)
	EditorStateMachine.add_state(GoToState)
	isOK = isOK and EditorStateMachine.set_state(TileState)
	isOK = isOK and EditorStateMachine.add_default_state(TileState)
	if(not isOK):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()
	
	SaveManager.MapTemp = MapData.get_new(EDITOR_SAVE_NAME)
	SaveManager.MapEdit = MapData.get_new(EDITOR_SAVE_NAME)
	
	if(EditorStateMachine.force_call(TileState, "fill_item_list", []) == StateMachine.ERROR):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()
	
	update_EditedMap_chunks()

### ----------------------------------------------------
# Drawing
### ----------------------------------------------------

func _input(event:InputEvent) -> void:
	EditorStateMachine.update_state_input(event)
	if(event is InputEventMouseMotion):
		_draw_loaded_chunks()
		_draw_selected_chunk()
		_draw_selected_tile()
		queue_redraw()

# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selected_tile() -> void:
	var cellPos:Vector2i = VectorTools.scale_down_vec2i(
		get_global_mouse_position(), GLOBAL.TILEMAPS.BASE_SCALE)
	var rect := Rect2i(cellPos * GLOBAL.TILEMAPS.BASE_SCALE, GLOBAL.TILEMAPS.TILE_SIZE)
	UIElement.CellText.text = "Cell: " + str(cellPos)
	add_function_to_DrawQueue(Callable(self, "draw_rect").bindv([rect, Color.CRIMSON, false, 1]))

# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selected_chunk() -> void:
	var chunkPos:Vector2i = VectorTools.scale_down_vec2i(
		get_global_mouse_position(), GLOBAL.TILEMAPS.CHUNK_SIZE * GLOBAL.TILEMAPS.BASE_SCALE)
	var rect := Rect2i(chunkPos * CHUNK_PIXEL_SIZE, CHUNK_SIZE_VECTOR)
	UIElement.ChunkText.text = "Chunk: " + str(chunkPos)
	add_function_to_DrawQueue(Callable(self, "draw_rect").bindv([rect, Color.BLACK, false, 1]))

# Draws squares around all loaded chunks
func _draw_loaded_chunks():
	for pos in $TileMapManager.RenderedChunks:
		var rect := Rect2i(VectorTools.vec3i_vec2i(pos) * CHUNK_PIXEL_SIZE, CHUNK_SIZE_VECTOR)
		add_function_to_DrawQueue(Callable(self, "draw_rect").bindv([rect, Color.GRAY, false, 1]))

### ----------------------------------------------------
# Signals
### ----------------------------------------------------

func _on_terrain_select_item_selected(index: int) -> void:
	EditorStateMachine.force_call(TileState, "change_currentLayerID", [index])

func _on_item_list_item_selected(index: int) -> void:
	EditorStateMachine.force_call(TileState, "change_terrainIndex", [index])

func _on_filter_input_text_submitted(new_text: String) -> void:
	EditorStateMachine.redirect_signal(FilterState, "change_filter", [new_text])
	EditorStateMachine.redirect_signal(FilterState, "end_state", [])

func _on_save_input_text_submitted(new_text: String) -> void:
	EditorStateMachine.redirect_signal(SaveState, "save_map", [new_text])
	EditorStateMachine.redirect_signal(SaveState, "end_state", [])

func _on_load_input_text_submitted(new_text: String) -> void:
	EditorStateMachine.redirect_signal(LoadState, "load_map", [new_text])
	EditorStateMachine.redirect_signal(LoadState, "end_state", [])

func _on_goto_input_text_submitted(new_text: String) -> void:
	EditorStateMachine.redirect_signal(GoToState, "change_coords", [new_text])
	EditorStateMachine.redirect_signal(GoToState, "end_state", [])

### ----------------------------------------------------
# Update chunks
### ----------------------------------------------------

# Renders chunks as in normal game based on camera position (as simulated entity)
func update_EditedMap_chunks() -> void:
	var camChunk := VectorTools.scale_down_vec2i($Cam.global_position, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	GLOBAL.ChunkManager.update(VectorTools.vec2i_vec3i(camChunk, TileState.currentElevation))

### ----------------------------------------------------
# MISC
### ----------------------------------------------------

func _show_lineEdit(LENode:Control) -> void:
	LENode.show()
	LENode.grab_focus()

func _hide_lineEdit(LENode:Control) -> void:
	LENode.hide()

func editor_save_map(mapName:String) -> bool:
	var path := SaveManager.TEMP_FOLDER + mapName + ".res"
	var result := MapData.save_MapData_to_path(path, SaveManager.MapEdit)
	if(result != OK):
		Logger.log_err(["Failed to save map to path: ", path])
		return false
	Logger.log_msg(["Saved map: ", mapName])
	return true

func editor_load_map(mapName:String) -> bool:
	var path := SaveManager.TEMP_FOLDER + mapName + ".res"
	var TempResult := MapData.load_MapData_from_path(path)
	if(TempResult == null):
		Logger.log_err(["Failed to load map from path: ", path])
		return false
	SaveManager.MapEdit = TempResult
	Logger.log_msg(["Loaded map: ", mapName])
	return true
