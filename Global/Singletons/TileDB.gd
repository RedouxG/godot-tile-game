### ----------------------------------------------------
### Stores information about tiles
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

enum LAYERS {Background, Foreground, Enviroment}
var DictionaryDB:Dictionary = {}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	var TM:TileMap = preload("res://Scenes/SimulationManager/TileMap/TileMapManager.tscn").instantiate()
	var TS:TileSet = preload("res://Scenes/SimulationManager/TileMap/TileSet.tres")
	if(not check_database_compatible(TM, TS)):
		Logger.logErr(["TileDB is not compatible with TileSet!"])
		get_tree().quit()
	else:
		Logger.LogMsg(["TileDB is compatible with TileSet"])

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

func add_record(key:String, TD:TerrainData) -> void:
	DictionaryDB[key] = TD

func get_record(key:String) -> TerrainData:
	return DictionaryDB.get(key)

# Checks if database has records for all existing terrains in tileset
func check_database_compatible(TM:TileMap, TS:TileSet) -> bool:
	var isOK := true
	var Terrains := TileMapTools.get_terrains(TS)
	for terrainSetID in Terrains:
		for terrainName in Terrains[terrainSetID]:
			if(get_record(terrainName) == null):
				push_warning("Database is missing record for: ", terrainName)
				isOK = false
	
	for layerID in LAYERS.values():
		if(not layerID in TileMapTools.get_layers(TM)):
			push_warning("layerID does not exist in TileMap: ", layerID)
			isOK = false
	return isOK
