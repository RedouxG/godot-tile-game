### ----------------------------------------------------
# DESC
### ----------------------------------------------------

extends RefCounted
class_name SaveManager

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Static util
### ----------------------------------------------------

static func load_MapData_from_path(path:String) -> MapData:
	var TempRef = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if(not TempRef is MapData):
		return null
	return TempRef

static func save_MapData_to_path(path:String, Map:MapData) -> int:
	return ResourceSaver.save(Map, path, ResourceSaver.FLAG_COMPRESS)
