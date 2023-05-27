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
@onready var PREC_RENDER_RANGE := VectorTools.vec3i_get_range_2d(Vector3i(0,0,0), GLOBAL.SIMULATION.SIM_RANGE)

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
# Functions
### ----------------------------------------------------

# Default editor state
class TILE_STATE extends SMState:
	enum DRAW_MODE {Single, Multiple}
	var currentDrawMode:int = DRAW_MODE.Single
	var DrawSelector:Selector
	
	var TM:TileMap
	var TS:TileSet
	var Cam:Camera2D

	var KeyInputHandler = InputHandler.new()
	
	var MAX_LAYERS:int = 0
	
	var ShownTerrains:Array = []
	var terrainIndex := 0    # Terrain index in ShownTerrains
	var currentLayerID := 0  # LayerID is the same as layerID
	
	var currentElevation:int = 0
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
		TM = caller.TM
		TS = caller.TS
		Cam = caller.get_node("Cam")
		MAX_LAYERS = TM.get_layers_count()
		for index in MAX_LAYERS:
			Caller.UIElement.TerrainSelect.add_item(TM.get_layer_name(index) + " (" + str(index) + ")",index)
		DrawSelector = DrawNode.Selector.new(caller)
	
	func _state_set() -> void:
		KeyInputHandler.add_function(KEY_E, Callable(self, "add_currentLayerID").bindv([1]))
		KeyInputHandler.add_function(KEY_Q, Callable(self, "add_currentLayerID").bindv([-1]))
		KeyInputHandler.add_function(KEY_X, Callable(self, "add_terrainIndex").bindv([1]))
		KeyInputHandler.add_function(KEY_Z, Callable(self, "add_terrainIndex").bindv([-1]))
		KeyInputHandler.add_function(KEY_MINUS, Callable(self, "change_elevation").bindv([-1]))
		KeyInputHandler.add_function(KEY_EQUAL, Callable(self, "change_elevation").bindv([1]))
		KeyInputHandler.add_function(KEY_1, Callable(self, "set_draw_mode").bindv([DRAW_MODE.Single]))
		KeyInputHandler.add_function(KEY_2, Callable(self, "set_draw_mode").bindv([DRAW_MODE.Multiple]))
		KeyInputHandler.add_function(KEY_F, Callable(StateMaster, "set_state").bindv([Caller.FilterState]))
		KeyInputHandler.add_function(KEY_CTRL, Callable(StateMaster, "set_state").bindv([Caller.SaveState]))
		KeyInputHandler.add_function(KEY_ALT, Callable(StateMaster, "set_state").bindv([Caller.LoadState]))
		KeyInputHandler.add_function(KEY_G, Callable(StateMaster, "set_state").bindv([Caller.GoToState]))
	
	func tile_place_input(event:InputEvent) -> void:
		if(not (event is InputEventMouseButton or event is InputEventMouseMotion)):
			return
		if(not ShownTerrains.size() > 0): 
			return
		
		if(currentDrawMode == DRAW_MODE.Single):
			if(event.button_mask == MOUSE_BUTTON_MASK_LEFT):  
				set_selected_tile(ShownTerrains[terrainIndex])
		if(currentDrawMode == DRAW_MODE.Multiple):
			if(event.is_action_pressed("LeftClick")):  
				DrawSelector.start(Caller.get_global_mouse_position())
			if(event.is_action_released("LeftClick")):
				DrawSelector.end()
			if(DrawSelector.isActive):
				DrawSelector.draw_selected_area(Caller.get_global_mouse_position())

		if(event.button_mask == MOUSE_BUTTON_MASK_RIGHT): 
			set_selected_tile(-1)
	
	func camera_movement_input(event:InputEvent) -> void:
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
				Cam.zoom_camera(-Cam.zoomValue)
			elif(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
				Cam.zoom_camera(Cam.zoomValue)
		if(event is InputEventMouseMotion):
			if(event.button_mask == MOUSE_BUTTON_MASK_MIDDLE):
				Cam.position -= event.relative * Cam.zoom
				Caller.update_EditedMap_chunks()
	
	# This could be an input map but doing it with ifs is good enough
	func update_input(event:InputEvent) -> void:
		if(not UITools.is_mouse_on_ui(Caller.UIElement.SelectionUI, Caller.UIElement.UIRoot)):
			camera_movement_input(event)
			tile_place_input(event)
		KeyInputHandler.handle_input_keycode(event)
	
	func set_draw_mode(drawMode:int) -> void:
		if(not drawMode in DRAW_MODE.values()):
			return
		currentDrawMode = drawMode
		Caller.UIElement.DrawModeText.text = DRAW_MODE.keys()[drawMode] + " selection mode"

	func add_currentLayerID(value:int) -> void:
		currentLayerID += value
		change_currentLayerID(currentLayerID)
	
	func change_currentLayerID(value:int) -> void:
		currentLayerID = value
		currentLayerID = clamp(currentLayerID, 0, MAX_LAYERS - 1)
		fill_item_list()
		terrainIndex = 0
		Caller.UIElement.TerrainSelect.select(currentLayerID)
		if(ShownTerrains.size() < 0): 
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
	
		var TerrainSystemLayer := TILEDB.get_terrains_on_layer(currentLayerID)
		for terrainID in TerrainSystemLayer:
			var terrainName:String = TerrainSystemLayer[terrainID]
			if(Caller.FilterState.filter != ""):
				if(not Caller.FilterState.filter.to_lower() in terrainName.to_lower()): 
					continue
			
			var TerrainImage := BetterTerrainTools.get_terrain_image(TS, terrainID)
			var TerrainTexture:Texture2D = ImageTexture.create_from_image(TerrainImage)
			Caller.UIElement.TileItemList.add_item(terrainName, TerrainTexture, true)
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
		if(not Caller.editor_save_map(mapName)):
			Logger.log_err(["Failed to save: ", mapName])
	
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
		if(not Caller.editor_load_map(mapName)):
			Logger.log_err(["Failed to load: ", mapName])
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
	var chunksToRender := VectorTools.vec3i_get_precomputed_range(
		VectorTools.vec2i_vec3i(camChunk, TileState.currentElevation),
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
