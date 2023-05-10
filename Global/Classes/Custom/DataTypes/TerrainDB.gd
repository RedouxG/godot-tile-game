### ----------------------------------------------------
### Stores information about terrains
### ----------------------------------------------------

extends RefCounted
class_name TerrainDB

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["DictionaryDB"])
var DictionaryDB:Dictionary = {}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Setup database when object is created, updated by hand
func _init() -> void:
	add_record("StoneWall", TerrainData.new().set_description("This is a stone wall."))
	add_record("StoneFloor", TerrainData.new().set_description("This is a stone floor."))
	add_record("DirtWall", TerrainData.new().set_description("This is a dirt wall."))
	add_record("DirtFloor", TerrainData.new().set_description("This is a dirt floor."))

func add_record(key:String, TD:TerrainData) -> void:
	DictionaryDB[key] = TD

func get_record(key:String) -> TerrainData:
	return DictionaryDB.get(key)

# Checks if database has records for all existing terrains in tileset
func check_database_compatible(TS:TileSet) -> bool:
	var isOK := true
	var Terrains := TileMapTools.get_terrains(TS)
	for terrainSetID in Terrains:
		for terrainName in Terrains[terrainSetID]:
			if(get_record(terrainName) == null):
				push_warning("Database is missing record for: ", terrainName)
				isOK = false
	return isOK

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> TerrainDB:
	Saver.set_properties_str(data)
	return self
