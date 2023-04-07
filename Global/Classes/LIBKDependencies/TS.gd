### ----------------------------------------------------
### Helps with TileSets
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
### FUNCTIONS
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
