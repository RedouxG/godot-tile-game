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
	Parent =         $UIElements/MC,
	TileScroll =     $UIElements/MC/GC/TileScroll,
	TMSelect =       $UIElements/MC/GC/TileScroll/TMSelect,
	TileList =       $UIElements/MC/GC/TileScroll/ItemList,
	SaveEdit =       $UIElements/MC/GC/Info/SaveEdit,
	LoadEdit =       $UIElements/MC/GC/Info/LoadEdit,
	FilterEdit =     $UIElements/MC/GC/Info/FilterEdit,
	GotoEdit =       $UIElements/MC/GC/Info/Goto,
	ChunkLabel =     $UIElements/MC/GC/Info/Chunk,
	ElevationLabel = $UIElements/MC/GC/Info/Elevation,
	CellLabel =      $UIElements/MC/GC/Info/Cell,
	Filter =         $UIElements/MC/GC/Info/Filter,
}

@onready var TM:TileMap = $TileMapManager
@onready var TS:TileSet = $TileMapManager.tile_set

var EditorStateMachine := StateMachine.new()
@onready var SelectState := SLCT_STATE.new(self, "SLCT_STATE")
@onready var FilterState := FLTR_STATE.new(self, "FLTR_STATE")
@onready var SaveState := SAVE_STATE.new(self, "SAVE_STATE")
@onready var LoadState := LOAD_STATE.new(self, "LOAD_STATE")
@onready var GoToState := GOTO_STATE.new(self, "GOTO_STATE")

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
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
	
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	
	SaveManager.MapTemp = MapData.get_new(EDITOR_SAVE_NAME)
	SaveManager.MapEdit = MapData.get_new(EDITOR_SAVE_NAME)
	
	if(EditorStateMachine.force_call(SelectState, "fill_item_list", []) == StateMachine.ERROR):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()

### ----------------------------------------------------
# Drawing
### ----------------------------------------------------

func _draw():
	var mousePos:Vector2 = get_global_mouse_position()
	_draw_selection_square(mousePos)
	_draw_selection_chunk(mousePos)
	#_draw_loaded_chunks()

# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selection_square(mousePos:Vector2) -> void:
	var cellPos:Vector2i = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.BASE_SCALE)
	var rect = Rect2i(cellPos * GLOBAL.TILEMAPS.BASE_SCALE, GLOBAL.TILEMAPS.TILE_SIZE)
	UIElement.CellLabel.text = "Cell: " + str(cellPos)
	draw_rect(rect, Color.CRIMSON,false,1)

# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2) -> void:
	var chunkScale:int = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
	var chunkPos:Vector2i = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE * GLOBAL.TILEMAPS.BASE_SCALE)
	var rect = Rect2i(chunkPos * chunkScale, Vector2(chunkScale, chunkScale))
	
	UIElement.ChunkLabel.text = "Chunk: " + str(chunkPos)
	draw_rect(rect, Color.BLACK, false, 1)

# Draws squares around all loaded chunks
func _draw_loaded_chunks():
	for posV3 in $TileMapManager.RenderedChunks:
		var chunkScale:int = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
		var posV2:Vector2 = VectorTools.vec3i_vec2i(posV3) * chunkScale
		var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
		draw_rect(rect, Color.RED, false, 1)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _input(event:InputEvent) -> void:
	EditorStateMachine.update_state_input(event)
	queue_redraw()
	update_EditedMap_chunks()

# Default editor state
class SLCT_STATE extends SMState:
	var TM:TileMap
	var TS:TileSet
	var Cam:Camera2D
	
	var MAX_LAYERS:int = 0
	
	var ShownTerrains:Array = []
	var terrainIndex := 0 # Terrain index in ShownTerrains
	var currentLayerID := 0
	
	var currentElevation:int = 0
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
		TM = caller.TM
		TS = caller.TS
		Cam = caller.get_node("Cam")
		MAX_LAYERS = TS.get_terrain_sets_count()
	
	func mouse_input(event:InputEvent) -> void:
		if(event is InputEventMouseButton):
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP):
				Cam.zoom_camera(-Cam.zoomValue)
			elif(event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
				Cam.zoom_camera(Cam.zoomValue)
		if(event is InputEventMouseMotion):
			if(event.button_mask == MOUSE_BUTTON_MASK_MIDDLE):
				Cam.position -= event.relative * Cam.zoom
		
		if(event is InputEventMouseButton or event is InputEventMouseMotion):
			if(not ShownTerrains.size() > 0): 
				return
			if event.button_mask == MOUSE_BUTTON_MASK_LEFT:  
				set_selected_tile(ShownTerrains[terrainIndex])
			if event.button_mask == MOUSE_BUTTON_MASK_RIGHT: 
				set_selected_tile(-1)
	
	# This could be an input map but doing it with ifs is good enough
	func update_input(event:InputEvent) -> void:
		if(not LibK.UI.is_mouse_on_ui(Caller.UIElement.TileScroll, Caller.UIElement.Parent)):
			mouse_input(event)
		if not event is InputEventKey: 
			return
		
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["E"])): 
			switch_currentLayerID(1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Q"])): 
			switch_currentLayerID(-1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["X"])):
			switch_terrainIndex(1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Z"])): 
			switch_terrainIndex(-1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["-"])):
			change_elevation(-1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["="])):
			change_elevation(1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["F"])):
			StateMaster.set_state(Caller.FilterState)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["LCtrl"])):
			StateMaster.set_state(Caller.SaveState)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["LAlt"])):
			StateMaster.set_state(Caller.LoadState)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["G"])):
			StateMaster.set_state(Caller.GoToState)
	
	func switch_currentLayerID(value:int) -> void:
		currentLayerID += value
		clamp(currentLayerID, 0, Caller.MAX_LAYERS - 1)
		fill_item_list()
		Caller.UIElement.TMSelect.select(Caller.layerID)
		terrainIndex = 0
	
	func change_currentLayerID(value:int) -> void:
		currentLayerID = value
		clamp(currentLayerID, 0, Caller.MAX_LAYERS - 1)
		fill_item_list()
		Caller.UIElement.TMSelect.select(Caller.layerID)
		terrainIndex = 0
	
	func switch_terrainIndex(value:int) -> void:
		terrainIndex += value
		clamp(terrainIndex, 0, Caller.UIElement.TileList.get_item_count()-1)
		Caller.UIElement.TileList.select(terrainIndex)
	
	func change_terrainIndex(value:int) -> void:
		terrainIndex = value
		clamp(terrainIndex, 0, Caller.UIElement.TileList.get_item_count()-1)
		Caller.UIElement.TileList.select(terrainIndex)
	
	func set_selected_tile(tileID:int) -> void:
		var mousePos:Vector2i = TM.local_to_map(Caller.get_global_mouse_position())
		var pos:Vector3i = VectorTools.vec2i_vec3i(mousePos, currentElevation)
		var chunkPos:Vector3i = VectorTools.vec2i_vec3i(
			VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE),
			currentElevation)
		if(not chunkPos in TM.RenderedChunks): return
		
		if(tileID == -1):
			SaveManager.MapTemp.rem_terrain_on(pos, currentLayerID)
		else:
			SaveManager.MapTemp.set_terrain_on(pos, currentLayerID, ShownTerrains[terrainIndex])
		TM.refresh_tile(pos)
	
	func change_elevation(direction:int) -> void:
		currentElevation += direction
		Caller.UIElement.ElevationLabel.text = "Elevation: " + str(currentElevation)
		TM.unload_all()

	# Fills item list with TileMap tiles
	func fill_item_list() -> void:
		ShownTerrains.clear()
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
			Caller.UIElement.TileList.add_item(terrainName, terrainTexture, true)
			ShownTerrains.append(terrainID)

class FLTR_STATE extends SMState:
	var filter := ""
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.FilterEdit)
	
	func change_filter(new_text:String) -> void:
		filter = new_text
		Caller.UIElement.Filter.text = "Filter: " + "\"" + filter + "\""
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.FilterEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

class SAVE_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.SaveEdit)
	
	func save_map(mapName:String) -> void:
		if(not SaveManager.editor_save_map(mapName)):
			Logger.logErr(["Failed to save: ", mapName])
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.SaveEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

class LOAD_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.LoadEdit)
	
	func load_map(mapName:String) -> void:
		var Temp := SQLSave.new(mapName, SaveManager.MAP_FOLDER)
		if(not SaveManager.editor_load_map(mapName)):
			Logger.logErr(["Failed to load: ", mapName])
		Caller.TM.refresh_all_chunks()
	
	func end_state() -> void:
		Caller.get_node("TileMapManager").unload_all_chunks()
		Caller._hide_lineEdit(Caller.UIElement.LoadEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

class GOTO_STATE extends SMState:
	func _init(caller:Node, name:String) -> void:
		super(caller, name)

	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.GotoEdit)
	
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
		Caller._hide_lineEdit(Caller.UIElement.GotoEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

### ----------------------------------------------------
# Signals
### ----------------------------------------------------

func _on_ItemList_item_selected(index:int) -> void:
	EditorStateMachine.force_call(SelectState, "change_terrainIndex", [index])

func _on_TMSelect_item_selected(index:int) -> void:
	EditorStateMachine.force_call(SelectState, "change_currentLayerID", [index])

func _on_Filter_text_entered(new_text: String) -> void:
	EditorStateMachine.redirect_signal(FilterState, "change_filter", [new_text])
	EditorStateMachine.redirect_signal(FilterState, "end_state", [])

func _on_SaveEdit_text_entered(mapName:String) -> void:
	EditorStateMachine.redirect_signal(SaveState, "save_map", [mapName])
	EditorStateMachine.redirect_signal(SaveState, "end_state", [])

func _on_LoadEdit_text_entered(mapName:String) -> void:
	EditorStateMachine.redirect_signal(LoadState, "load_map", [mapName])
	EditorStateMachine.redirect_signal(LoadState, "end_state", [])

func _on_GOTO_text_entered(new_text:String) -> void:
	EditorStateMachine.redirect_signal(GoToState, "change_coords", [new_text])
	EditorStateMachine.redirect_signal(GoToState, "end_state", [])
	

### ----------------------------------------------------
# Update chunks
### ----------------------------------------------------

# Renders chunks as in normal game based on camera position (as simulated entity)
func update_EditedMap_chunks() -> void:
	var camChunk := VectorTools.scale_down_vec2i($Cam.global_position, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	var chunksToRender := VectorTools.vec3i_get_range_2d(VectorTools.vec2i_vec3i(camChunk, SelectState.currentElevation), 1)

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
	$Cam.inputActive = false
	LENode.show()
	LENode.grab_focus()

func _hide_lineEdit(LENode:Control) -> void:
	$Cam.inputActive = true
	LENode.hide()
