### ----------------------------------------------------
### Sublib for optimization related tasks
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Used for stuff like deciding tile type depending on noise
# IN: {Tile: percent,Tile2: percent}
# OUT: [tile,tile, ..., tile2]
static func range_to_array(sourceDict:Dictionary) -> Array:
	var keyArray = []
	keyArray.resize(100)
	
	var currentIndex:int = 0
	for tile in sourceDict:
		var percent:int = int(sourceDict[tile]*100)
		if (currentIndex + percent) > 100:
			Logger.logErr(["currentIndex + percent is larger than possible max index: ", currentIndex + percent])
			return []
		
		for index in range(currentIndex, currentIndex + percent):
			keyArray[index] = tile
		
		currentIndex += percent
	
	return keyArray

# Used with range_to_array function
# IN: 0.64
# OUT: 164
static func noise_to_index(noise:float) -> int:
	return int((noise*100+100)/2)
