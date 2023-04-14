### ----------------------------------------------------
### Input management for MapEditor
### Key inputs:
### 	Q and E - Switch TileMap
### 	Z and X - Switch tile
### 	Alt     - Load current map
### 	Ctrl    - Save current map
### 	F       - Add filter to listed tiles
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var TileSelect := {
	filter = "",			# Item filter keyword
	allTileMaps = [],		# List of all tilemaps
	tileData = [],			# Data regarding tiles (same order as all tilemaps)
	shownTiles = [],		# List of all show tiles (in TileList)
	TMIndex = 0,			# TileMap index (allTileMaps)
	listIndex = 0,			# Index of selected item
}

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

var EditorStateMachine := StateMachine.new()
@onready var NormalState := NORM_STATE.new(self)
@onready var FilterState := FLTR_STATE.new(self)
@onready var SaveState := SAVE_STATE.new(self)
@onready var LoadState := LOAD_STATE.new(self)
@onready var GoToState := GOTO_STATE.new(self)

var inputActive := true

const EDITOR_SAVE_NAME := "EDITOR"
var EditedMap:SQLSave

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	var isOK := true
	EditorStateMachine.add_state(NormalState)
	EditorStateMachine.add_state(FilterState)
	EditorStateMachine.add_state(SaveState)
	EditorStateMachine.add_state(LoadState)
	EditorStateMachine.add_state(GoToState)
	isOK = isOK and EditorStateMachine.set_state(NormalState)
	isOK = isOK and EditorStateMachine.add_default_state(NormalState)
	if(not isOK):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()
	
	RenderingServer.set_default_clear_color(Color.DARK_SLATE_BLUE)
	TileSelect.allTileMaps = $TileMapManager.TileMaps
	
	EditedMap = SQLSave.new(EDITOR_SAVE_NAME, SaveManager.MAP_FOLDER)
	if(not EditedMap.create_new_save(TileSelect.allTileMaps)):
		push_error("Failed to init MapEditor")
		get_tree().quit()
	if(not EditedMap.load(TileSelect.allTileMaps)):
		push_error("Failed to init MapEditor")
		get_tree().quit()
	
	_init_TM_selection()
	_init_tile_select()
	if(EditorStateMachine.force_call(NormalState, "switch_TM_selection", [0]) == StateMachine.ERROR):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()

### ----------------------------------------------------
# Init
### ----------------------------------------------------

func _init_TM_selection():
	for tileMap in TileSelect.allTileMaps:
		var TMName:String = tileMap.get_name()
		UIElement.TMSelect.add_item (TMName)

func _init_tile_select():
	for tileMap in TileSelect.allTileMaps:
		TileSelect.tileData.append(TileMapTools.get_tile_names_and_IDs(tileMap.tile_set))

### ----------------------------------------------------
# Drawing
### ----------------------------------------------------
func _draw():
	var mousePos:Vector2 = get_global_mouse_position()
	_draw_selection_square(mousePos)
	_draw_selection_chunk(mousePos)
	_draw_loaded_chunks()

# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selection_square(mousePos:Vector2):
	var size = Vector2(GLOBAL.TILEMAPS.BASE_SCALE,GLOBAL.TILEMAPS.BASE_SCALE)
	var cellPosV2:Vector2 = LibK.Vectors.scale_down_vec2(mousePos, GLOBAL.TILEMAPS.BASE_SCALE)
	var posV2:Vector2 = cellPosV2 * GLOBAL.TILEMAPS.BASE_SCALE
	
	var rect = Rect2(posV2,size)
	UIElement.CellLabel.text = "Cell: " + str(cellPosV2)
	
	draw_rect(rect,Color.CRIMSON,false,1)

# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2):
	var chunkScale:int = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
	var chunkV2:Vector2 = LibK.Vectors.scale_down_vec2(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	var posV2:Vector2 = chunkV2 * chunkScale
	var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
	
	UIElement.ChunkLabel.text = "Chunk: " + str(chunkV2)
	draw_rect(rect, Color.BLACK, false, 1)

# Draws squares around all loaded chunks
func _draw_loaded_chunks():
	for posV3 in $TileMapManager.RenderedChunks:
		var chunkScale:int = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
		var posV2:Vector2 = LibK.Vectors.vec3_vec2(posV3) * chunkScale
		var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
		draw_rect(rect, Color.RED, false, 1)


### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _input(event:InputEvent) -> void:
	if(not inputActive): return
	EditorStateMachine.update_state_input(event)
	update()
	update_EditedMap_chunks()

# Default editor state
class NORM_STATE extends SMState:
	var TileMapManager:Node2D
	var Cam:Camera2D
	var T:Node2D # Short for caller
	
	func _init(caller:Node2D) -> void:
		super(caller)
		TileMapManager = caller.get_node("TileMapManager")
		Cam = caller.get_node("Cam")
		T = caller

	static func get_name() -> String:
		return "NORM_STATE"
	
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
			if(not T.TileSelect.shownTiles.size() > 0): 
				return
			if event.button_mask == MOUSE_BUTTON_MASK_LEFT:  
				var tileID:int = T.TileSelect.shownTiles[T.TileSelect.listIndex][1]
				set_selected_tile(tileID)
			if event.button_mask == MOUSE_BUTTON_MASK_RIGHT: 
				set_selected_tile(-1)
	
	# This could be an input map but doing it with ifs is good enough
	func update_input(event:InputEvent) -> void:
		if(not LibK.UI.is_mouse_on_ui(T.UIElement.TileScroll, T.UIElement.Parent)):
			mouse_input(event)
		if not event is InputEventKey: 
			return
		
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["E"])): 
			switch_TM_selection(T.TileSelect.TMIndex + 1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Q"])): 
			switch_TM_selection(T.TileSelect.TMIndex - 1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["X"])):
			switch_tile_selection(T.TileSelect.listIndex + 1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Z"])): 
			switch_tile_selection(T.TileSelect.listIndex - 1)
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
	
	func switch_TM_selection(value:int) -> void:
		T.TileSelect.TMIndex = value
		if(T.TileSelect.TMIndex > (T.TileSelect.allTileMaps.size() - 1)): 
			T.TileSelect.TMIndex = 0
		if(T.TileSelect.TMIndex < 0): 
			T.TileSelect.TMIndex = (T.TileSelect.allTileMaps.size() - 1)
		
		T.TileSelect.listIndex = 0
		fill_item_list()
		
		T.UIElement.TMSelect.select(T.TileSelect.TMIndex)
		switch_tile_selection(T.TileSelect.listIndex)
	
	func switch_tile_selection(value:int) -> void:
		T.TileSelect.listIndex = value
		if(T.TileSelect.listIndex > (T.UIElement.TileList.get_item_count() - 1)): 
			T.TileSelect.listIndex = 0
		if(T.TileSelect.listIndex < 0): 
			T.TileSelect.listIndex = (T.UIElement.TileList.get_item_count() - 1)
		
		T.UIElement.TileList.select(T.TileSelect.listIndex)
	
	func set_selected_tile(tileID:int) -> void:
		var tileMap:TileMap = T.TileSelect.allTileMaps[T.TileSelect.TMIndex]
		var mousePos:Vector2 = tileMap.local_to_map(Caller.get_global_mouse_position())
		var posV3:Vector3 = LibK.Vectors.vec2_vec3(mousePos, Cam.currentElevation)
		var chunkV3:Vector3 = LibK.Vectors.vec2_vec3(
			LibK.Vectors.scale_down_vec2(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE),
			Cam.currentElevation)
		if(not chunkV3 in TileMapManager.RenderedChunks): return
		var TMName = tileMap.get_name()
		
		if(tileID == -1):
			T.EditedMap.remove_tile_from_TileData(TMName,posV3)
		else:
			if(not T.EditedMap.add_tile_to_TileData_on(posV3, TMName, tileID)):
				Logger.logErr(["Failed to set tile: ", [posV3, TMName, tileID]])
		TileMapManager.refresh_tile_on(posV3, T.EditedMap.get_TileData_on(posV3))
	
	func change_elevation(direction:int) -> void:
		Cam.currentElevation += direction
		T.UIElement.ElevationLabel.text = "Elevation: " + str(Cam.currentElevation)
		TileMapManager.unload_all_chunks()

	# Fills item list with TileMap tiles
	func fill_item_list() -> void:
		T.UIElement.TileList.clear()
		T.TileSelect.shownTiles.clear()
		
		var tileMap:TileMap = T.TileSelect.allTileMaps[T.TileSelect.TMIndex]
		for packed in T.TileSelect.tileData[T.TileSelect.TMIndex]:
			var tileName:String = packed[0]
			var tileID:int = packed[1]
			var tileTexture:Texture2D = TileMapTools.get_tile_texture(tileID, tileMap.tile_set)

			if(T.TileSelect.filter != ""):
				if(not T.TileSelect.filter.to_lower() in tileName.to_lower()): 
					continue
			T.UIElement.TileList.add_item(tileName,tileTexture,true)
			T.TileSelect.shownTiles.append([tileName,tileID])

class FLTR_STATE extends SMState:
	func _init(caller:Node2D) -> void:
		super(caller)
		pass

	static func get_name() -> String:
		return "FLTR_STATE"
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.FilterEdit)
	
	func change_filter(new_text:String) -> void:
		Caller.TileSelect.filter = new_text
		Caller.UIElement.Filter.text = "Filter: " + "\"" + Caller.TileSelect.filter + "\""
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.FilterEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()
			

class SAVE_STATE extends SMState:
	func _init(caller:Node) -> void:
		super(caller)
		pass

	static func get_name() -> String:
		return "SAVE_STATE"
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.SaveEdit)
	
	func save_map(mapName:String) -> void:
		if(not Caller.EditedMap.save(SaveManager.MAP_FOLDER + mapName + ".db")):
			Logger.logErr(["Failed to save: ", mapName])
	
	func end_state() -> void:
		Caller._hide_lineEdit(Caller.UIElement.SaveEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

class LOAD_STATE extends SMState:
	func _init(caller:Node2D) -> void:
		super(caller)
		pass

	static func get_name() -> String:
		return "LOAD_STATE"
	
	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.LoadEdit)
	
	func load_map(mapName:String) -> void:
		var Temp := SQLSave.new(mapName, SaveManager.MAP_FOLDER)
		if(Temp.load(Caller.TileSelect.allTileMaps)):
			Caller.EditedMap = Temp
		else:
			Logger.logErr(["Failed to load: ", mapName])
	
	func end_state() -> void:
		Caller.get_node("TileMapManager").unload_all_chunks()
		Caller._hide_lineEdit(Caller.UIElement.LoadEdit)
		StateMaster.set_default_state()
	
	func update_input(event:InputEvent) -> void:
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["ESC"])):
			end_state()

class GOTO_STATE extends SMState:
	func _init(caller:Node2D) -> void:
		super(caller)
		pass

	static func get_name() -> String:
		return "GOTO_STATE"

	func _state_set() -> void:
		Caller._show_lineEdit(Caller.UIElement.GotoEdit)
	
	func change_coords(new_text:String = "NOFILTER") -> void:
		if(new_text == "NOFILTER"): return

		var coords:Array = new_text.split(" ")
		if(not coords.size() >= 2): return
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
	EditorStateMachine.force_call(NormalState, "switch_tile_selection", [index])

func _on_TMSelect_item_selected(index:int) -> void:
	EditorStateMachine.force_call(NormalState, "switch_TM_selection", [index])

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
	var camChunk := LibK.Vectors.scale_down_vec2($Cam.global_position, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	var chunksToRender := LibK.Vectors.vec3_get_range_2d(LibK.Vectors.vec2_vec3(camChunk, $Cam.currentElevation), 1)

	# Loading chunks that are not yet rendered
	for chunkV3 in chunksToRender:
		if($TileMapManager.RenderedChunks.has(chunkV3)): continue
		$TileMapManager.load_chunk_to_tilemap(chunkV3, 
			EditedMap.get_TileData_on_chunk(chunkV3, GLOBAL.TILEMAPS.CHUNK_SIZE))
	
	# Unload old chunks that are not meant to be seen
	for i in range($TileMapManager.RenderedChunks.size() - 1, -1, -1):
		var chunkV3:Vector3 = $TileMapManager.RenderedChunks[i]
		if(chunksToRender.has(chunkV3)): continue
		$TileMapManager.RenderedChunks.remove(i)
		$TileMapManager.unload_chunk_from_tilemap(chunkV3)
	
	$TileMapManager.update_all_TM_bitmask()

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
