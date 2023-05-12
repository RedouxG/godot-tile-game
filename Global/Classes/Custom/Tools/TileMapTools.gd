### ----------------------------------------------------
### Wrapper around godot built in TileMap
### ----------------------------------------------------

extends Script
class_name TileMapTools

### ----------------------------------------------------
# FUNCTIONS
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

# Returns dictionary of type {Vector2i:[altID, ...]}
static func get_tileIDs_and_alts(Source:TileSetAtlasSource) -> Dictionary:
	var result:Dictionary = {}
	for sourceIndex in Source.get_tiles_count():
		var tileID := Source.get_tile_id(sourceIndex)
		result[tileID] = []
		for altIndex in Source.get_alternative_tiles_count(tileID):
			result[tileID].append(Source.get_alternative_tile_id(tileID, altIndex))
	return result

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

# Updates terrain bitmask for a given empty pos
static func update_removed_cell(TM:TileMap, pos:Vector2i, layerID:int) -> void:
	TM.set_cells_terrain_connect(layerID, [pos], layerID, -1)

# {TerrainSetID : [TerrainName, ...]}
static func get_terrains(TS:TileSet) -> Dictionary:
	var output := {}
	for terrainSetID in TS.get_terrain_sets_count():
		output[terrainSetID] = get_terrainNames(TS, terrainSetID)
	return output

static func get_layers(TM:TileMap) -> Array[int]:
	var output:Array[int] = []
	for i in TM.get_layers_count():
		output.append(i)
	return output

static func get_tile_image(TS:TileSet, sourceID:int, atlasCoords:Vector2i) -> Image:
	var source:TileSetAtlasSource = TS.get_source(sourceID)
	var textureRegion:Rect2i = source.get_tile_texture_region(atlasCoords)
	return source.texture.get_image().get_region(textureRegion)
