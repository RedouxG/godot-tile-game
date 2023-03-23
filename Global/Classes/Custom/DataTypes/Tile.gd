### ----------------------------------------------------
### Global class / data type that is used as storage of tile data on a given position
### ----------------------------------------------------

extends RefCounted
class_name Tile

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Saver := ObjectSaver.new(self, ["DB", "EntityData"])

# Stores IDs on TileSets
var DB:Dictionary # {TSName:tileID, ...}

# Stores data regardning an entity on this tile
var EntityData:String

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(tsdict:Dictionary = {}, eData:String = "") -> void:
	DB = tsdict
	EntityData = eData

func add_to_DB(TSName:String, tileID:int) -> void:
	if(not DB.has(TSName)): DB[TSName] = {}
	DB[TSName] = tileID

func get_from_DB(TSName:String) -> int:
	if(not DB.has(TSName)): return -1
	return DB[TSName]

func erase_from_DB(TSName:String) -> bool:
	return DB.erase(TSName)

func check_DB_compatible(TSControl:Dictionary) -> bool:
	var isOK := true
	for TSName in DB:
		if(not TSControl.has(TSName)):
			Logger.logErr(["Check check_DB_compatible failed! TSControl is missing TSName: ", TSName],[])
			isOK = false
			break
		if(not TSControl[TSName].has(DB[TSName])): 
			Logger.logErr(["Check check_DB_compatible failed! TSControl is missing tile from DB: ", DB[TSName]],[])
			isOK = false
			break
	return isOK

# checks whether TileData is empty (no data is saved)
func is_empty() -> bool:
	if(DB.is_empty() and EntityData.is_empty()): return true
	return false

### ----------------------------------------------------
# SAVE
### ----------------------------------------------------

func _to_string() -> String:
	return Saver.get_properties_str()

func from_string(data:String) -> Tile:
	Saver.set_properties_str(data)
	return self
