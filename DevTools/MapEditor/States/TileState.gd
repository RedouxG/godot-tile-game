### ----------------------------------------------------
# Drawing state for map editor
### ----------------------------------------------------

extends SMState

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

enum DRAW_MODE {Single, Multiple}
var currentDrawMode:int = DRAW_MODE.Single
var DrawSelector:DrawNode.Selector

var TM:TileMap
var TS:TileSet
var Cam:Camera2D

var KeyInputHandler = InputHandler.new(200)

var MAX_LAYERS:int = 0

var ShownTerrains:Array = []
var terrainIndex := 0    # Terrain index in ShownTerrains
var currentLayerID := 0  # LayerID is the same as layerID

var currentElevation:int = 0

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

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
	KeyInputHandler.add_function(KEY_E, Callable(self, "increment_layer"))
	KeyInputHandler.add_function(KEY_Q, Callable(self, "decrement_layer"))
	KeyInputHandler.add_function(KEY_X, Callable(self, "increment_terrain"))
	KeyInputHandler.add_function(KEY_Z, Callable(self, "decrement_terrain"))
	KeyInputHandler.add_function(KEY_MINUS, Callable(self, "increment_elevation"))
	KeyInputHandler.add_function(KEY_EQUAL, Callable(self, "decrement_elevation"))
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
			for cellPos in DrawSelector.get_cells_in_selected_area(Caller.get_global_mouse_position(), GLOBAL.TILEMAPS.BASE_SCALE):
				_set_tile_on_pos(VectorUtils.vec2i_vec3i(cellPos, currentElevation), ShownTerrains[terrainIndex])
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
	if(not UIUtils.is_mouse_on_ui(Caller.UIElement.SelectionUI)):
		camera_movement_input(event)
		tile_place_input(event)
	KeyInputHandler.handle_input_keycode(event)

func set_draw_mode(drawMode:int) -> void:
	if(not drawMode in DRAW_MODE.values()):
		return
	currentDrawMode = drawMode
	Caller.UIElement.DrawModeText.text = DRAW_MODE.keys()[drawMode] + " selection mode"

func decrement_layer() -> void:
	currentLayerID = NumberFormatter.clamp_decrement_int(currentLayerID, 0, MAX_LAYERS - 1)
	change_layer(currentLayerID)

func increment_layer() -> void:
	currentLayerID = NumberFormatter.clamp_increment_int(currentLayerID, 0, MAX_LAYERS - 1)
	change_layer(currentLayerID)

func change_layer(value:int) -> void:
	currentLayerID = value
	currentLayerID = clamp(currentLayerID, 0, MAX_LAYERS - 1)
	fill_item_list()
	terrainIndex = 0
	Caller.UIElement.TerrainSelect.select(currentLayerID)
	if(ShownTerrains.size() < 0): 
		Caller.UIElement.TileItemList.select(terrainIndex)

func increment_terrain() -> void:
	terrainIndex = NumberFormatter.clamp_increment_int(terrainIndex, 0, Caller.UIElement.TileItemList.get_item_count()-1)
	change_terrain(terrainIndex)

func decrement_terrain() -> void:
	terrainIndex = NumberFormatter.clamp_decrement_int(terrainIndex, 0, Caller.UIElement.TileItemList.get_item_count()-1)
	change_terrain(terrainIndex)

func change_terrain(value:int) -> void:
	terrainIndex = value
	terrainIndex = clamp(terrainIndex, 0, Caller.UIElement.TileItemList.get_item_count()-1)
	Caller.UIElement.TileItemList.select(terrainIndex)

func set_selected_tile(terrainID:int) -> void:
	var tilePos:Vector3i = VectorUtils.vec2i_vec3i(
		TM.local_to_map(Caller.get_global_mouse_position()), currentElevation)
	_set_tile_on_pos(tilePos, terrainID)

func increment_elevation() -> void:
	currentElevation = NumberFormatter.clamp_increment_int(
		currentElevation, GLOBAL.GAME.MIN_ELEVATION, GLOBAL.GAME.MAX_ELEVATION)
	change_elevation(currentElevation)

func decrement_elevation() -> void:
	currentElevation = NumberFormatter.clamp_decrement_int(
		currentElevation, GLOBAL.GAME.MIN_ELEVATION, GLOBAL.GAME.MAX_ELEVATION)
	change_elevation(currentElevation)

func change_elevation(e:int) -> void:
	currentElevation = e
	Caller.UIElement.ElevationText.text = "Elevation: " + str(currentElevation)
	TM.refresh_all_chunks()

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
		
		var TerrainImage := BetterTerrainUtils.get_terrain_image(TS, terrainID)
		var TerrainTexture:Texture2D = ImageTexture.create_from_image(TerrainImage)
		Caller.UIElement.TileItemList.add_item(terrainName, TerrainTexture, true)
		ShownTerrains.append(terrainID)

func _set_tile_on_pos(tilePos:Vector3i, terrainID:int) -> void:
	var chunkPos:Vector3i = VectorUtils.scale_down_vec3i_noZ(tilePos, GLOBAL.TILEMAPS.CHUNK_SIZE)
	if(not chunkPos in TM.RenderedChunks): 
		return
	if(terrainID == -1):
		SaveManager.rem_terrain_on(tilePos, currentLayerID)
	else:
		SaveManager.set_terrain_on(tilePos, currentLayerID, terrainID)
	TM.refresh_tile(tilePos)
