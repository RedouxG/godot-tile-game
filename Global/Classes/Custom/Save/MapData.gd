### ----------------------------------------------------
# Map
### ----------------------------------------------------

extends Resource
class_name MapData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["Data", "TS_CONTROL", "MapName"])

# Stores map data
@export var Data := Dictionary() # { posV3:Tile }

# Stores information about used tilemaps
@export var TS_CONTROL := Dictionary()
@export var MapName := "Default"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func create_new(TileMaps:Array) -> void:
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		TS_CONTROL[TSName] = {}
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			TS_CONTROL[TSName][tileNamesIDs[index][1]] = tileNamesIDs[index][0]

# Check if tilemaps are compatible with TS_CONTROL tilemaps
func check_compatible(TileMaps:Array) -> bool:
	var isOK := true
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		if not TS_CONTROL.has(TSName):
			Logger.logErr(["TS_CONTROL is missing TSName: " + TSName])
			isOK = false
			continue
		
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			var tileName:String = tileNamesIDs[index][0]
			var tileID:int = tileNamesIDs[index][1]
			if not TS_CONTROL[TSName].has(tileID):
				Logger.logErr(["TS_CONTROL is missing tileID: ", tileID])
				isOK = false
				continue
			
			if TS_CONTROL[TSName][tileID] != tileName:
				Logger.logErr(["TileName doesn't match for tileID: ", tileID, " | ", tileName, " != ", TS_CONTROL[TSName][tileID]])
				isOK = false
				continue
	return isOK

### ----------------------------------------------------
# API
### ----------------------------------------------------

# Sets Tile in Data on posV3
func set_on(posV3:Vector3, tile:Tile) -> void:
	Data[posV3] = str(tile)

# Gets Tile on position from Data
func get_on(posV3:Vector3) -> Tile:
	if(not Data.has(posV3)):
		return Tile.new()
	return Tile.new().from_str(Data[posV3])

# Removes position from Data
func rem_on(posV3:Vector3) -> bool:
	return Data.erase(posV3)

# Returns chunk of given size
func get_chunk(chunkPosV3:Vector3, chunkSize:int) -> Array:
	var result := []
	for posV3 in LibK.vec3_get_pos_in_chunk(chunkPosV3, chunkSize):
		if(not Data.has(posV3)):
			continue
		result.append(Tile.new().from_str(Data[posV3]))
	return result

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> MapData:
	Saver.set_properties_str(data)
	return self
