### ----------------------------------------------------
# Map
### ----------------------------------------------------

extends Resource
class_name MapData

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var objectMapper := ObjectMapper.new(self, ["Data", "mapName"])

@export var Data := Dictionary() # { pos:MapTileStr }
@export var mapName := "Default"

### ----------------------------------------------------
# API
### ----------------------------------------------------

func set_on(pos:Vector3i, mapTile:MapTile) -> void:
    Data[pos] = str(mapTile)

func get_on(pos:Vector3i) -> MapTile:
    if(not Data.has(pos)):
        return null
    return MapTile.new().from_string(Data[pos])

func rem_on(pos:Vector3i) -> bool:
    return Data.erase(pos)

func rem_terrain_on(pos:Vector3i, layerID:int) -> void:
    var MTile := get_on(pos)
    if(MTile == null): return
    
    MTile.rem_terrain(layerID)
    if(MTile.is_empty()): 
        rem_on(pos)
    else:
        set_on(pos, MTile)

func set_terrain_on(pos:Vector3i, layerID:int, terrainID:int) -> void:
    var MTile := get_on(pos)
    if(MTile == null):
        MTile = MapTile.new()
    MTile.set_terrain(layerID, terrainID)
    set_on(pos, MTile)

# Returns chunk of given size
func get_chunk(chunkPos:Vector3i, chunkSize:int) -> Dictionary:
    var result := {}
    for pos in VectorUtilsExt.vec3i_get_positions_in_chunk(chunkPos, chunkSize):
        if(not Data.has(pos)):
            result[pos] = null
            continue
        result[pos] = MapTile.new().from_string(Data[pos])
    return result

### ----------------------------------------------------
# SaveManager
### ----------------------------------------------------

func _to_string() -> String:
    return objectMapper.to_string()

func from_string(data:String) -> MapData:
    return objectMapper.from_string(data)

### ----------------------------------------------------
# Static util
### ----------------------------------------------------

static func load_MapData_from_path(path:String) -> MapData:
    if(not FileUtils.file_exists(path)):
        return null
    var TempRef = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
    if(not TempRef is MapData):
        return null
    return TempRef

static func save_MapData_to_path(path:String, Map:MapData) -> int:
    return ResourceSaver.save(Map, path, ResourceSaver.FLAG_COMPRESS)

static func get_new(name:String) -> MapData:
    var NewMap := MapData.new()
    NewMap.mapName = name
    return NewMap
