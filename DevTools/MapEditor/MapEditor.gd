### ----------------------------------------------------
### Input management for MapEditor
### Key inputs:
### 	Q and E - Switch layer
### 	Z and X - Switch tile
### 	Alt     - Load current map
### 	Ctrl    - Save current map
### 	F       - Add filter to listed tiles
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const EDITOR_SAVE_NAME := "EDITOR"

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
}

@onready var TM:TileMap = $TileMapManager
@onready var TS:TileSet = $TileMapManager.tile_set
@onready var PREC_RENDER_RANGE := VectorTools.vec3i_get_range_2d(Vector3i(0,0,0), GLOBAL.SIMULATION.SIM_RANGE)

var EditorStateMachine := StateMachine.new()
@onready var SelectState := SLCT_STATE.new(self, "SLCT_STATE")
@onready var FilterState := FLTR_STATE.new(self, "FLTR_STATE")
@onready var SaveState := SAVE_STATE.new(self, "SAVE_STATE")
@onready var LoadState := LOAD_STATE.new(self, "LOAD_STATE")
@onready var GoToState := GOTO_STATE.new(self, "GOTO_STATE")

const CHUNK_PIXEL_SIZE = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
const CHUNK_SIZE_VECTOR = Vector2i(CHUNK_PIXEL_SIZE, CHUNK_PIXEL_SIZE)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	
	var isOK := true
	EditorStateMachine.add_state(SelectState)
	EditorStateMachine.add_state(FilterState)
	EditorStateMachine.add_state(SaveState)
	EditorStateMachine.add_state(LoadState)
	EditorStateMachine.add_state(GoToState)
	isOK = isOK and EditorStateMachine.set_state(SelectState)
	isOK = isOK and EditorStateMachine.add_default_state(SelectState)
	if(not isOK):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()
	
	SaveManager.MapTemp = MapData.get_new(EDITOR_SAVE_NAME)
	SaveManager.MapEdit = MapData.get_new(EDITOR_SAVE_NAME)
	
	if(EditorStateMachine.force_call(SelectState, "fill_item_list", []) == StateMachine.ERROR):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()
	
	update_EditedMap_chunks()

### ----------------------------------------------------
# Drawing
### ----------------------------------------------------

func _input(event:InputEvent) -> void:
	EditorStateMachine.update_state_input(event)
	if(event is InputEventMouseMotion):
		queue_redraw()

func _draw():
	var mousePos:Vector2 = get_global_mouse_position()
	_draw_loaded_chunks()
	_draw_selected_chunk(mousePos)
	_draw_selected_tile(mousePos)

# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selected_tile(mousePos:Vector2) -> void:
	var cellPos:Vector2i = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.BASE_SCALE)
	var rect := Rect2i(cellPos * GLOBAL.TILEMAPS.BASE_SCALE, GLOBAL.TILEMAPS.TILE_SIZE)
	UIElement.CellText.text = "Cell: " + str(cellPos)
	draw_rect(rect, Color.CRIMSON, false, 1)

# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selected_chunk(mousePos:Vector2) -> void:
	var chunkPos:Vector2i = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE * GLOBAL.TILEMAPS.BASE_SCALE)
	var rect := Rect2i(chunkPos * CHUNK_PIXEL_SIZE, CHUNK_SIZE_VECTOR)
	UIElement.ChunkText.text = "Chunk: " + str(chunkPos)
	draw_rect(rect, Color.BLACK, false, 1)

# Draws squares around all loaded chunks
func _draw_loaded_chunks():
	for pos in $TileMapManager.RenderedChunks:
		draw_rect(Rect2i(VectorTools.vec3i_vec2i(pos) * CHUNK_PIXEL_SIZE, CHUNK_SIZE_VECTOR), Color.GRAY, false, 1)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Default editor state
class SLCT_STATE extends SMState:
	var TM:TileMap
	var TS:TileSet
	var Cam:Camera2D
	
	var MAX_LAYERS:int = 0
	
	var ShownTerrains:Array = []
	var terrainIndex := 0    # Terrain index in ShownTerrains
	var currentLayerID := 0  # LayerID is the same as TerrainSetID
	
	var currentElevation:int = 0
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
		TM = caller.TM
		TS = caller.TS
		Cam = caller.get_node("Cam")
		MAX_LAYERS = TileMapTools.get_terrainSets_as_layers(TM)
		for index in MAX_LAYERS:
			Caller.UIElement.TerrainSelect.add_item(
				TM.get_layer_name(index) + " (" + str(index) + ")",
				index)
	
	func mouse_input(event:InputEvent) -> void:
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
				Cam.zoom_camera(-Cam.zoomValue)
			elif(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
				Cam.zoom_camera(Cam.zoomValue)
		if(event is InputEventMouseMotion):
			if(event.button_mask == MOUSE_BUTTON_MASK_MIDDLE):
				Cam.position -= event.relative * Cam.zoom
				Caller.update_EditedMap_chunks()
		
		if(event is InputEventMouseButton or event is InputEventMouseMotion):
			if(not ShownTerrains.size() > 0): 
				return
			if(event.button_mask == MOUSE_BUTTON_MASK_LEFT):  
				set_selected_tile(ShownTerrains[terrainIndex])
			if(event.button_mask == MOUSE_BUTTON_MASK_RIGHT): 
				set_selected_tile(-1)
	
	# This could be an input map but doing it with ifs is good enough
	func update_input(event:InputEvent) -> void:
		if(not LibK.UI.is_mouse_on_ui(Caller.UIElement.SelectionUI, Caller.UIElement.UIRoot)):
			mouse_input(event)
		
		if(InputTools.is_key_pressed(event, KEY_E)):
			add_currentLayerID(1)
		elif(InputTools.is_key_pressed(event, KEY_Q)): 
			add_currentLayerID(-1)
		elif(InputTools.is_key_pressed(event, KEY_X)):
			add_terrainIndex(1)
		elif(InputTools.is_key_pressed(event, KEY_Z)): 
			add_terrainIndex(-1)
		elif(InputTools.is_key_pressed(event, KEY_MINUS)):
			change_elevation(-1)
		elif(InputTools.is_key_pressed(event, KEY_EQUAL)):
			change_elevation(1)
		elif(InputTools.is_key_pressed(event, KEY_F)):
			StateMaster.set_state(Caller.FilterState)
		elif(InputTools.is_key_pressed(event, KEY_CTRL)):
			StateMaster.set_state(Caller.SaveState)
		elif(InputTools.is_key_pressed(event, KEY_ALT)):
			StateMaster.set_state(Caller.LoadState)
		elif(InputTools.is_key_pressed(event, KEY_G)):
			StateMaster.set_state(Caller.GoToState)
	
	func add_currentLayerID(value:int) -> void:
		currentLayerID += value
		currentLayerID = clamp(currentLayerID, 0, MAX_LAYERS - 1)
		fill_item_list()
		terrainIndex = 0
		Caller.UIElement.TerrainSelect.select(currentLayerID)
		Caller.UIElement.TileItemList.select(terrainIndex)
	
	func change_currentLayerID(value:int) -> void:
		currentLayerID = value
		currentLayerID = clamp(currentLayerID, 0, MAX_LAYERS - 1)
		fill_item_list()
		terrainIndex = 0
		Caller.UIElement.TerrainSelect.select(currentLayerID)
		Caller.UIElement.TileItemList.select(terrainIndex)
	
	func add_terrainIndex(value:int) -> void:
		terrainIndex += value
		terrainIndex = clamp(terrainIndex, 0, Caller.UIElement.TileItemList.get_item_count()-1)
		Caller.UIElement.TileItemList.select(terrainIndex)
	
	func change_terrainIndex(value:int) -> void:
		terrainIndex = value
		terrainIndex = clamp(terrainIndex, 0, Caller.UIElement.TileItemList.get_item_count()-1)
		Caller.UIElement.TileItemList.select(terrainIndex)
	
	func set_selected_tile(terrainID:int) -> void:
		var tilePos:Vector3i = VectorTools.vec2i_vec3i(
			TM.local_to_map(Caller.get_global_mouse_position()),
			currentElevation)
		var chunkPos:Vector3i = VectorTools.scale_down_vec3i_noZ(
			tilePos,
			GLOBAL.TILEMAPS.CHUNK_SIZE)
		if(not chunkPos in TM.RenderedChunks): return
		
		if(terrainID == -1):
			SaveManager.rem_terrain_on(tilePos, currentLayerID)
			TileMapTools.update_removed_cell(TM, VectorTools.vec3i_vec2i(tilePos), currentLayerID)
		else:
			SaveManager.set_terrain_on(tilePos, currentLayerID, terrainID)
		TM.refresh_tile(tilePos)
	
	func change_elevation(direction:int) -> void:
		currentElevation += direction
		Caller.UIElement.ElevationText.text = "Elevation: " + str(currentElevation)
		TM.unload_all()

	# Fills item list with TileMap tiles
	func fill_item_list() -> void:
		ShownTerrains.clear()
		Caller.UIElement.TileItemList.clear()
		
		var TerrainIDs = TileMapTools.get_terrainIDs(TS, currentLayerID)
		var TerrainNames = TileMapTools.get_terrainNames(TS, currentLayerID)
		for index in TerrainIDs.size():
			var terrainID:int = TerrainIDs[index]
			var terrainName:String = TerrainNames[index]
			if(Caller.FilterState.filter != ""):
				if(not Caller.FilterState.filter.to_lower() in terrainName.to_lower()): 
					continue
			var terrainTexture:Texture2D = TileMapTools.get_terrain_Texture2D(
				TM, currentLayerID, terrainID)
			Caller.UIElement.TileItemList.add_item(terrainName, terrainTexture, true)
			ShownTerrains.append(terrainID)

class FLTR_STATE extends SMState:
	var filter := ""
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.FilterInput)
	
	func change_filter(new_text:String) -> void:
		filter = new_text
		Caller.UIElement.FilterInput.text = "FilterInput: " + "\"" + filter + "\""
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.FilterInput)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
			end_state()

class SAVE_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.SaveInput)
	
	func save_map(mapName:String) -> void:
		if(not SaveManager.editor_save_map(mapName)):
			Logger.logErr(["Failed to save: ", mapName])
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.SaveInput)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
			end_state()

class LOAD_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.LoadInput)
	
	func load_map(mapName:String) -> void:
		var Temp := SQLSave.new(mapName, SaveManager.TEMP_FOLDER)
		if(not SaveManager.editor_load_map(mapName)):
			Logger.logErr(["Failed to load: ", mapName])
		Caller.TM.refresh_all_chunks()
		
	
	func end_state() -> void:
		Caller.get_node("TileMapManager").unload_all()
		Caller._hide_lineEdit(Caller.UIElement.LoadInput)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
			end_state()

class GOTO_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)

	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.GotoInput)
	
	func change_coords(new_text:String) -> void:
		var coords:Array = new_text.split(" ")
		if(not coords.size() >= 2): 
			return
		if(not coords[0].is_valid_int() and coords[1].is_valid_int()):
			return
		
		Caller.get_node("Cam").global_position = Vector2(
			int(coords[0]) * GLOBAL.TILEMAPS.BASE_SCALE,
			int(coords[1]) * GLOBAL.TILEMAPS.BASE_SCALE)
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.GotoInput)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
			end_state()

### ----------------------------------------------------
# Signals
### ----------------------------------------------------

func _on_terrain_select_item_selected(index: int) -> void:
	EditorStateMachine.force_call(SelectState, "change_currentLayerID", [index])

func _on_item_list_item_selected(index: int) -> void:
	EditorStateMachine.force_call(SelectState, "change_terrainIndex", [index])

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
	var chunksToRender := VectorTools.vec3i_get_precomputed_range(
		VectorTools.vec2i_vec3i(camChunk, SelectState.currentElevation),
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

### ----------------------------------------------------
# MISC
### ----------------------------------------------------

func _show_lineEdit(LENode:Control) -> void:
	LENode.show()
	LENode.grab_focus()

func _hide_lineEdit(LENode:Control) -> void:
	LENode.hide()
