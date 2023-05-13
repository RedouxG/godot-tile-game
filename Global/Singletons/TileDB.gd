### ----------------------------------------------------
### Stores information about tiles
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

enum LAYERS {Background, Foreground, Enviroment}
const TS:TileSet = preload("res://Scenes/SimulationManager/TileMap/TileSet.tres")
var TM:TileMap = preload("res://Scenes/SimulationManager/TileMap/TileMapManager.tscn").instantiate()

var DictionaryDB := {}  # Database of all records {terrainName:TerrainData}
var TerrainSystem := {} # {LayerID:{terrainID:terrainName}}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	if(not check_database_compatible()):
		Logger.logErr(["TILEDB is not compatible with TileSet!"])
		get_tree().quit()
	else:
		Logger.LogMsg(["TILEDB is compatible with TileSet"])
	_setup_TerrainSystem()

# Setup database when object is created, updated by hand
func _init() -> void:
	add_record("StoneWall", 
		TerrainData.new(LAYERS.Background).set_description("This is a stone wall."))
	add_record("StoneFloor", 
		TerrainData.new(LAYERS.Background).set_description("This is a stone floor."))
	add_record("DirtWall", 
		TerrainData.new(LAYERS.Background).set_description("This is a dirt wall."))
	add_record("DirtFloor", 
		TerrainData.new(LAYERS.Background).set_description("This is a dirt floor."))

func _setup_TerrainSystem() -> void:
	for terrainName in DictionaryDB:
		var td:TerrainData = DictionaryDB[terrainName]
		var terrainID := BetterTerrainTools.get_terrain_id(TS, terrainName)
		if(not TerrainSystem.has(td.layerID)):
			TerrainSystem[td.layerID] = {}
		if(terrainID == -1): continue
		TerrainSystem[td.layerID][terrainID] = terrainName

func add_record(key:String, TD:TerrainData) -> void:
	DictionaryDB[key] = TD

func get_record(key:String) -> TerrainData:
	return DictionaryDB.get(key)

func get_terrains_on_layer(layerID:int) -> Dictionary:
	return TerrainSystem.get(layerID, {}).duplicate(true)

# Checks if database has records for all existing terrains in tileset
func check_database_compatible() -> bool:
	var isOK := true
	var Terrains := BetterTerrainTools.get_terrains(TS)
	for terrainName in Terrains:
		if(get_record(terrainName) == null):
			push_warning("Database is missing record for: ", terrainName)
			isOK = false
	
	for layerID in LAYERS.values():
		if(not layerID in TileMapTools.get_layers(TM)):
			push_warning("layerID does not exist in TileMap: ", layerID)
			isOK = false
	return isOK