### ----------------------------------------------------
### Wrapper around godot built in TileSet
### ----------------------------------------------------

extends Script
class_name TSUtils

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

static func get_sources(TS:TileSet) -> Array[TileSetAtlasSource]:
	var result:Array[TileSetAtlasSource] = []
	for index in TS.get_source_count():
		var sourceID := TS.get_source_id(index)
		result.append(TS.get_source(sourceID))
	return result

static func get_tiledatas(Source:TileSetAtlasSource) -> Array[TileData]:
	var output:Array[TileData] = []
	for t in Source.get_tiles_count():
		var coord := Source.get_tile_id(t)
		for a in Source.get_alternative_tiles_count(coord):
			var alternate := Source.get_alternative_tile_id(coord, a)
			output.append(Source.get_tile_data(coord, alternate))
	return output

# { coord:[tiledata(alt1), tiledata(alt2), ...]}
static func get_tiledatas_coords(Source:TileSetAtlasSource) -> Dictionary:
	var output:Dictionary = {}
	for t in Source.get_tiles_count():
		var coord := Source.get_tile_id(t)
		output[coord] = []
		for a in Source.get_alternative_tiles_count(coord):
			var alternate := Source.get_alternative_tile_id(coord, a)
			output[coord].append(Source.get_tile_data(coord, alternate))
	return output

static func get_terrainIDs(TS:TileSet, terrainSetID:int) -> Array[int]:
	var result:Array[int] = []
	for terrainID in TS.get_terrains_count(terrainSetID):
		result.append(terrainID)
	return result

static func get_terrainNames(TS:TileSet, terrainSetID:int) -> Array[String]:
	var result:Array[String] = []
	for terrainID in TS.get_terrains_count(terrainSetID):
		result.append(TS.get_terrain_name(terrainSetID, terrainID))
	return result

# Returns tileIDs without alts
static func get_tileIDs(source:TileSetSource) -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for index in source.get_tiles_count():
		result.append(source.get_tile_id(index))
	return result

# {TerrainSetID : [TerrainName, ...]}
static func get_terrains(TS:TileSet) -> Dictionary:
	var output := {}
	for terrainSetID in TS.get_terrain_sets_count():
		output[terrainSetID] = get_terrainNames(TS, terrainSetID)
	return output

static func get_tile_image(TS:TileSet, sourceID:int, atlasCoords:Vector2i) -> Image:
	var source:TileSetAtlasSource = TS.get_source(sourceID)
	var textureRegion:Rect2i = source.get_tile_texture_region(atlasCoords)
	return source.texture.get_image().get_region(textureRegion)
