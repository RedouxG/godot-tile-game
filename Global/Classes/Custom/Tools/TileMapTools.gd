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

static func get_terrain_sourceID(TM:TileMap, terrainSetID:int, terrainID:int) -> int:
	var samplePos:= Vector2i(99999, 99999)
	var savedAltCoords := TM.get_cell_alternative_tile(0, samplePos)
	var savedAtlasCoords := TM.get_cell_atlas_coords(0, samplePos)
	var savedSourceID := TM.get_cell_source_id(0, samplePos)
	
	TM.set_cells_terrain_connect(0, [samplePos], terrainSetID, terrainID)
	var sourceID := TM.get_cell_source_id(0, samplePos)
	
	TM.set_cell(0, samplePos, savedSourceID, savedAtlasCoords, savedAltCoords)
	return sourceID

static func get_terrain_atlasCoords(TM:TileMap, terrainSetID:int, terrainID:int) -> Vector2i:
	var samplePos:= Vector2i(99999, 99999)
	var savedAltCoords := TM.get_cell_alternative_tile(0, samplePos)
	var savedAtlasCoords := TM.get_cell_atlas_coords(0, samplePos)
	var savedSourceID := TM.get_cell_source_id(0, samplePos)
	
	TM.set_cells_terrain_connect(0, [samplePos], terrainSetID, terrainID)
	var atlasCoords := TM.get_cell_atlas_coords(0, samplePos)
	
	TM.set_cell(0, samplePos, savedSourceID, savedAtlasCoords, savedAltCoords)
	return atlasCoords

static func get_tile_image(TS:TileSet, sourceID:int, atlasCoords:Vector2i) -> Image:
	var source:TileSetAtlasSource = TS.get_source(sourceID)
	var textureRegion:Rect2i = source.get_tile_texture_region(atlasCoords)
	return source.texture.get_image().get_region(textureRegion)

static func get_terrain_Texture2D(TM:TileMap, terrainSetID:int, terrainID:int) -> Texture2D:
	var sourceID:int = get_terrain_sourceID(TM, terrainSetID, terrainID)
	var atlasPos:Vector2i = get_terrain_atlasCoords(TM, terrainSetID, terrainID)
	var terrainImage:Image = get_tile_image(TM.tile_set, sourceID, atlasPos)
	return ImageTexture.create_from_image(terrainImage)

# Tilemaps are pretty cumbersome in godot 4 so i use this function as API for placing tiles
static func set_terrain(TM:TileMap, pos:Vector2i, layerID:int, terrainID:int) -> void:
	BetterTerrain.set_cell(TM, layerID, pos, terrainID)
	BetterTerrain.update_terrain_cell(TM, layerID, pos, true)

# Tilemaps are pretty cumbersome in godot 4 so i use this function as API for removing tiles
static func rem_terrain(TM:TileMap, pos:Vector2i, layerID:int) -> void:
	TM.erase_cell(layerID, pos)
	BetterTerrain.update_terrain_cell(TM, layerID, pos, true)
