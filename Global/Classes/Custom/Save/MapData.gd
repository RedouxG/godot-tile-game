### ----------------------------------------------------
# Map
### ----------------------------------------------------

extends Resource
class_name MapData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Stores map data
# { posV3:TileData }
var Data := Dictionary()
# Stores information about used tilemaps
var TS_CONTROL := Dictionary()
var MapName := "Default"

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
			Logger.logErr(["TS_CONTROL is missing TSName: " + TSName], get_stack())
			isOK = false
			continue
		
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			var tileName:String = tileNamesIDs[index][0]
			var tileID:int = tileNamesIDs[index][1]
			if not TS_CONTROL[TSName].has(tileID):
				Logger.logErr(["TS_CONTROL is missing tileID: ", tileID], get_stack())
				isOK = false
				continue
			
			if TS_CONTROL[TSName][tileID] != tileName:
				Logger.logErr(["TileName doesn't match for tileID: ", tileID, " | ", tileName, " != ", TS_CONTROL[TSName][tileID]],
					get_stack())
				isOK = false
				continue
	return isOK

### ----------------------------------------------------
# API
### ----------------------------------------------------

# Sets TileData in Data on posV3
func set_on(posV3:Vector3, tileData:TileData) -> void:
	Data[posV3] = str(tileData)

# Gets TileData on position from Data
func get_on(posV3:Vector3) -> TileData:
	if(not Data.has(posV3)):
		return TileData.new()
	return TileData.new().from_str(Data[posV3])

# Removes position from Data
func rem_on(posV3:Vector3) -> bool:
	return Data.erase(posV3)

# Returns chunk of given size
func get_chunk(chunkPosV3:Vector3, chunkSize:int) -> Array:
	var result := []
	for posV3 in LibK.vec3_get_pos_in_chunk(chunkPosV3, chunkSize):
		if(not Data.has(posV3)):
			continue
		result.append(TileData.new().from_str(Data[posV3]))
	return result

### ----------------------------------------------------
# UTIL
### ----------------------------------------------------

# Creates a copy of DataType from its data string
func from_str(s:String):
	return from_array(str_to_var(s))

# Creates copy of DataType data as string
func _to_string() -> String:
	return var_to_str(to_array())

# Converts DataType data to an array
func to_array() -> Array:
	var arr := []
	for propertyInfo in get_script().get_script_property_list():
		arr.append(get(propertyInfo.name))
	return arr

# Creates copy of DataType data as Array
func from_array(arr:Array):
	var index := 0
	for propertyInfo in get_script().get_script_property_list():
		set(propertyInfo.name, arr[index])
		index+=1
	return self
