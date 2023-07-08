### ----------------------------------------------------
### Lib for Betterterrain plugin
### ----------------------------------------------------

extends Script
class_name BetterTerrainUtils

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

# Returns all terrains metadata indexed by their id
static func get_terrains_meta(TS:TileSet) -> Array[Dictionary]:
    var output:Array[Dictionary] = []
    for index in range(BetterTerrain.terrain_count(TS)):
        output.append(BetterTerrain.get_terrain(TS, index))
    return output

static func get_terrains(TS:TileSet) -> Array[String]:
    var output:Array[String] = []
    for index in range(BetterTerrain.terrain_count(TS)):
        output.append(BetterTerrain.get_terrain(TS, index).name)
    return output

# Returns coords of terrain with center bitmask (single tile)
# Vector(-1, -1) if not found
static func get_terrain_representative_coords(TS:TileSet, terrainID:int) -> Vector2i:
    var Sources := TileSetUtils.get_sources(TS)
    for source in Sources:
        var TileDataCoords := TileSetUtils.get_tiledatas_coords(source)
        for coords in TileDataCoords:
            var meta:Dictionary = BetterTerrain._get_tile_meta(TileDataCoords[coords][0])
            if(meta.size() == 1 and meta.type == terrainID):
                return coords
    return Vector2i(-1,-1)

static func get_terrain_sourceID(TS:TileSet, terrainID:int) -> int:
    var Sources := TileSetUtils.get_sources(TS)
    var sourceIndex:int = 0
    for source in Sources:
        var TileDataCoords := TileSetUtils.get_tiledatas_coords(source)
        for coords in TileDataCoords:
            var meta:Dictionary = BetterTerrain._get_tile_meta(TileDataCoords[coords][0])
            if(meta.type == terrainID):
                return TS.get_source_id(sourceIndex)
    return -1

static func get_terrain_name(TS:TileSet, terrainID:int) -> String:
    return get_terrains(TS)[terrainID]

static func get_terrain_id(TS:TileSet, terrainName:String) -> int:
    return get_terrains(TS).find(terrainName)

static func get_terrain_image(TS:TileSet, terrainID:int) -> Image:
    return TileSetUtils.get_tile_image(TS, get_terrain_sourceID(TS, terrainID), get_terrain_representative_coords(TS,terrainID))
