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
@onready var NormalState := NORM_STATE.new(self, "NORM_STATE")
@onready var FilterState := FLTR_STATE.new(self, "FLTR_STATE")
@onready var SaveState := SAVE_STATE.new(self, "SAVE_STATE")
@onready var LoadState := LOAD_STATE.new(self, "LOAD_STATE")
@onready var GoToState := GOTO_STATE.new(self, "GOTO_STATE")

@onready var TileMapManager := $TileMapManager
@onready var MAX_LAYERS:int = TileMapManager.tile_set.get_terrain_sets_count()
const EDITOR_SAVE_NAME := "EDITOR"

# TerrainSetID is the same as layerID
# WallFloor is 0, Enviroment is 1
# {terrainSetID:{terrainID:terrainName}}
var TerrainList:Dictionary = {}

var selectedTerrainID := 0
var currentLayerName := ""
var currentLayerID := 0

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
	
	SaveManager.make_new_MapTemp(EDITOR_SAVE_NAME)
	if(not SaveManager._load_MapTemp(EDITOR_SAVE_NAME)):
		push_error("Failed to init MapEditor")
		get_tree().quit()
	
	init_TerrainList($TileMapManager.tile_set)
	
	if(EditorStateMachine.force_call(NormalState, "switch_TM_selection", [0]) == StateMachine.ERROR):
		push_error("Failed to init EditorStateMachine")
		get_tree().quit()

### ----------------------------------------------------
# Init
### ----------------------------------------------------

func init_TerrainList(TS:TileSet) -> void:
	for terrainSetID in MAX_LAYERS:
		TerrainList[terrainSetID] = {}
		var TerrainIDs := TileMapTools.get_terrainIDs(TS, terrainSetID)
		var TerrainNames:= TileMapTools.get_terrainNames(TS, terrainSetID)
		for index in range(TerrainIDs.size()):
			TerrainList[terrainSetID][TerrainIDs[index]] = TerrainNames[index]

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
	var size = Vector2(GLOBAL.TILEMAPS.BASE_SCALE, GLOBAL.TILEMAPS.BASE_SCALE)
	var cellPosV2:Vector2 = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.BASE_SCALE)
	var posV2:Vector2 = cellPosV2 * GLOBAL.TILEMAPS.BASE_SCALE
	
	var rect = Rect2(posV2,size)
	UIElement.CellLabel.text = "Cell: " + str(cellPosV2)
	
	draw_rect(rect,Color.CRIMSON,false,1)

# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2):
	var chunkScale:int = GLOBAL.TILEMAPS.BASE_SCALE * GLOBAL.TILEMAPS.CHUNK_SIZE
	var chunkV2:Vector2 = VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	var posV2:Vector2 = chunkV2 * chunkScale
	var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
	
	UIElement.ChunkLabel.text = "Chunk: " + str(chunkV2)
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
class NORM_STATE extends SMState:
	var TileMapManager:Node2D
	var Cam:Camera2D
	
	func _init(caller:Node, name:String) -> void:
		super(caller, name)
		TileMapManager = caller.TileMapManager
		Cam = caller.get_node("Cam")
	
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
			if(not Caller.TileSelect.shownTiles.size() > 0): 
				return
			if event.button_mask == MOUSE_BUTTON_MASK_LEFT:  
				var tileID:int = Caller.TileSelect.shownTiles[Caller.TileSelect.listIndex][1]
				set_selected_tile(tileID)
			if event.button_mask == MOUSE_BUTTON_MASK_RIGHT: 
				set_selected_tile(-1)
	
	# This could be an input map but doing it with ifs is good enough
	func update_input(event:InputEvent) -> void:
		if(not LibK.UI.is_mouse_on_ui(Caller.UIElement.TileScroll, Caller.UIElement.Parent)):
			mouse_input(event)
		if not event is InputEventKey: 
			return
		
		if(event.is_action_pressed(GLOBAL.INPUT_MAP["E"])): 
			switch_layer(1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Q"])): 
			switch_layer(-1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["X"])):
			switch_terrain(1)
		elif(event.is_action_pressed(GLOBAL.INPUT_MAP["Z"])): 
			switch_terrain(-1)
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
	
	func switch_layer(value:int) -> void:
		Caller.currentLayerID += value
		clamp(Caller.currentLayerID, 0, Caller.MAX_LAYERS - 1)
		fill_item_list()
		Caller.UIElement.TMSelect.select(Caller.currentLayerID)
		Caller.selectedTerrainID = 0
	
	func switch_terrain(value:int) -> void:
		Caller.selectedTerrainID += value
		clamp(Caller.selectedTerrainID, 0, Caller.UIElement.TileList.get_item_count()-1)
		Caller.UIElement.TileList.select(Caller.selectedTerrainID)
	
	func set_selected_tile(tileID:int) -> void:
		var TM:TileMap = TileMapManager
		var mousePos:Vector2 = TM.local_to_map(Caller.get_global_mouse_position())
		var pos:Vector3 = VectorTools.vec2i_vec3i(mousePos, Cam.currentElevation)
		var chunkPos:Vector3 = VectorTools.vec2i_vec3i(
			VectorTools.scale_down_vec2i(mousePos, GLOBAL.TILEMAPS.CHUNK_SIZE),
			Cam.currentElevation)
		if(not chunkPos in TM.RenderedChunks): return
		
		var terrainSetlayerID = TM.get_layer_name(Caller.currentLayerID)
		if(tileID == -1):
			SaveManager.MapTemp.rem_terrain_on(pos, terrainSetlayerID)
		else:
			SaveManager.MapTemp.set_terrain_on(pos, terrainSetlayerID, Caller.selectedTerrainID)
		TileMapManager.refresh_tile(pos)
	
	func change_elevation(direction:int) -> void:
		Cam.currentElevation += direction
		Caller.UIElement.ElevationLabel.text = "Elevation: " + str(Cam.currentElevation)
		TileMapManager.unload_all()

	# Fills item list with TileMap tiles
	func fill_item_list() -> void:
		var TerrainIDs = TileMapTools.get_terrainIDs(TileMapManager.tile_set, Caller.currentLayerID)
		var TerrainNames = TileMapTools.get_terrainNames(TileMapManager.tile_set, Caller.currentLayerID)
		for index in TerrainIDs.size():
			var terrainID:int = TerrainIDs[index]
			var terrainName:String = TerrainNames[index]
			if(Caller.FilterState.filter != ""):
				if(not Caller.FilterState.filter.to_lower() in terrainName.to_lower()): 
					continue
			#var tileTexture:Texture2D = TileMapTools.get_tile_texture(tileID, tileMap.tile_set)
			#Caller.UIElement.TileList.add_item(tileName,tileTexture,true)

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
		if(not Caller.EditedMap.save(SaveManager.MAP_FOLDER + mapName + ".db")):
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
	func _init(caller:Node, name:String) -> void:
		super(caller, name)

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
	var camChunk := VectorTools.scale_down_vec2i($Cam.global_position, GLOBAL.TILEMAPS.CHUNK_SIZE*GLOBAL.TILEMAPS.BASE_SCALE)
	var chunksToRender := VectorTools.vec3i_get_range_2d(VectorTools.vec2i_vec3i(camChunk, $Cam.currentElevation), 1)

	# Loading chunks that are not yet rendered
	for chunkPos in chunksToRender:
		if($TileMapManager.RenderedChunks.has(chunkPos)): continue
		$TileMapManager.load_chunk(chunkPos)
	
	# Unload old chunks that are not meant to be seen
	for i in range($TileMapManager.RenderedChunks.size() - 1, -1, -1):
		var chunkPos:Vector3i = $TileMapManager.RenderedChunks[i]
		if(chunksToRender.has(chunkPos)): continue
		$TileMapManager.unload_chunk(chunkPos)

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
