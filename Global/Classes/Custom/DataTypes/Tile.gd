### ----------------------------------------------------
### Global class / data type that is used as storage of tile data on a given position
### ----------------------------------------------------

extends DataType
class_name Tile

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Stores IDs on TileSets
var IDDict:Dictionary # {TSName:tileID, ...}

# Stores data regardning an entity on this tile
var EntityData:String

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(tsdict:Dictionary = {}, eData:String = "") -> void:
	IDDict = tsdict
	EntityData = eData

func add_to_IDDict(TSName:String, tileID:int) -> void:
	if(not IDDict.has(TSName)): IDDict[TSName] = {}
	IDDict[TSName] = tileID

func get_from_IDDict(TSName:String) -> int:
	if(not IDDict.has(TSName)): return -1
	return IDDict[TSName]

func erase_from_IDDict(TSName:String) -> bool:
	return IDDict.erase(TSName)

func check_IDDict_compatible(TSControl:Dictionary) -> bool:
	var isOK := true
	for TSName in IDDict:
		if(not TSControl.has(TSName)):
			Logger.logErr(["Check check_IDDict_compatible failed! TSControl is missing TSName: ", TSName],[])
			isOK = false
			break
		if(not TSControl[TSName].has(IDDict[TSName])): 
			Logger.logErr(["Check check_IDDict_compatible failed! TSControl is missing tile from IDDict: ", IDDict[TSName]],[])
			isOK = false
			break
	return isOK

# checks whether TileData is empty (no data is saved)
func is_empty() -> bool:
	if(IDDict.is_empty() and EntityData.is_empty()): return true
	return false
