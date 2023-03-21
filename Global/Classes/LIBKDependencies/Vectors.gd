### ----------------------------------------------------
### Sublib for Vector related functions
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


static func vec3i_get_range_2d(atPos:Vector3i, squareRange:int) -> Array:
	var result := []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			result.append(Vector3i(x,y,0) + atPos)
	return result

static func vec3i_get_range_3d(atPos:Vector3i, squareRange:int) -> Array:
	var result := []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			for z in range(-squareRange, squareRange + 1):
				result.append(Vector3i(x,y,z) + atPos)
	return result

static func vec2i_get_range(atPos:Vector2i, squareRange:int) -> Array[Vector2i]:
	var result:Array[Vector2i]= []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			result.append(Vector2i(x,y) + atPos)
	return result

### ----------------------------------------------------
# Conversion Vector2i / Vector3i
### ----------------------------------------------------


# Converts Vector2i to Vector3i
static func vec2i_vec3i(v:Vector2i, z:int = 0) -> Vector3i:
	return Vector3i(v.x, v.y, z)
	
#Converts Vector3i to Vector2i
static func vec3i_vec2i(v:Vector3i) -> Vector2i:
	return Vector2i(v.x, v.y)

### ----------------------------------------------------
# World to x (for Vector3i ommits third value)
### ----------------------------------------------------


static func scale_down_vec2i(v:Vector2i, scale:int) -> Vector2i:
	return Vector2i(v[0]/scale, v[1]/scale)

static func scale_down_vec3i(v:Vector3i, scale:int) -> Vector3i:
	return Vector3i(v[0]/scale, v[1]/(scale), v[2])

# Optimization for creating chunk of vectors (more than 2 times faster)
const OPT16_CHUNK = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5), Vector2i(0, 6), Vector2i(0, 7), Vector2i(0, 8), Vector2i(0, 9), Vector2i(0, 10), Vector2i(0, 11), Vector2i(0, 12), Vector2i(0, 13), Vector2i(0, 14), Vector2i(0, 15), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(1, 4), Vector2i(1, 5), Vector2i(1, 6), Vector2i(1, 7), Vector2i(1, 8), Vector2i(1, 9), Vector2i(1, 10), Vector2i(1, 11), Vector2i(1, 12), Vector2i(1, 13), Vector2i(1, 14), Vector2i(1, 15), Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3), Vector2i(2, 4), Vector2i(2, 5), Vector2i(2, 6), Vector2i(2, 7), Vector2i(2, 8), Vector2i(2, 9), Vector2i(2, 10), Vector2i(2, 11), Vector2i(2, 12), Vector2i(2, 13), Vector2i(2, 14), Vector2i(2, 15), Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3), Vector2i(3, 4), Vector2i(3, 5), Vector2i(3, 6), Vector2i(3, 7), Vector2i(3, 8), Vector2i(3, 9), Vector2i(3, 10), Vector2i(3, 11), Vector2i(3, 12), Vector2i(3, 13), Vector2i(3, 14), Vector2i(3, 15), Vector2i(4, 0), Vector2i(4, 1), Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4), Vector2i(4, 5), Vector2i(4, 6), Vector2i(4, 7), Vector2i(4, 8), Vector2i(4, 9), Vector2i(4, 10), Vector2i(4, 11), Vector2i(4, 12), Vector2i(4, 13), Vector2i(4, 14), Vector2i(4, 15), Vector2i(5, 0), Vector2i(5, 1), Vector2i(5, 2), Vector2i(5, 3), Vector2i(5, 4), Vector2i(5, 5), Vector2i(5, 6), Vector2i(5, 7), Vector2i(5, 8), Vector2i(5, 9), Vector2i(5, 10), Vector2i(5, 11), Vector2i(5, 12), Vector2i(5, 13), Vector2i(5, 14), Vector2i(5, 15), Vector2i(6, 0), Vector2i(6, 1), Vector2i(6, 2), Vector2i(6, 3), Vector2i(6, 4), Vector2i(6, 5), Vector2i(6, 6), Vector2i(6, 7), Vector2i(6, 8), Vector2i(6, 9), Vector2i(6, 10), Vector2i(6, 11), Vector2i(6, 12), Vector2i(6, 13), Vector2i(6, 14), Vector2i(6, 15), Vector2i(7, 0), Vector2i(7, 1), Vector2i(7, 2), Vector2i(7, 3), Vector2i(7, 4), Vector2i(7, 5), Vector2i(7, 6), Vector2i(7, 7), Vector2i(7, 8), Vector2i(7, 9), Vector2i(7, 10), Vector2i(7, 11), Vector2i(7, 12), Vector2i(7, 13), Vector2i(7, 14), Vector2i(7, 15), Vector2i(8, 0), Vector2i(8, 1), Vector2i(8, 2), Vector2i(8, 3), Vector2i(8, 4), Vector2i(8, 5), Vector2i(8, 6), Vector2i(8, 7), Vector2i(8, 8), Vector2i(8, 9), Vector2i(8, 10), Vector2i(8, 11), Vector2i(8, 12), Vector2i(8, 13), Vector2i(8, 14), Vector2i(8, 15), Vector2i(9, 0), Vector2i(9, 1), Vector2i(9, 2), Vector2i(9, 3), Vector2i(9, 4), Vector2i(9, 5), Vector2i(9, 6), Vector2i(9, 7), Vector2i(9, 8), Vector2i(9, 9), Vector2i(9, 10), Vector2i(9, 11), Vector2i(9, 12), Vector2i(9, 13), Vector2i(9, 14), Vector2i(9, 15), Vector2i(10, 0), Vector2i(10, 1), Vector2i(10, 2), Vector2i(10, 3), Vector2i(10, 4), Vector2i(10, 5), Vector2i(10, 6), Vector2i(10, 7), Vector2i(10, 8), Vector2i(10, 9), Vector2i(10, 10), Vector2i(10, 11), Vector2i(10, 12), Vector2i(10, 13), Vector2i(10, 14), Vector2i(10, 15), Vector2i(11, 0), Vector2i(11, 1), Vector2i(11, 2), Vector2i(11, 3), Vector2i(11, 4), Vector2i(11, 5), Vector2i(11, 6), Vector2i(11, 7), Vector2i(11, 8), Vector2i(11, 9), Vector2i(11, 10), Vector2i(11, 11), Vector2i(11, 12), Vector2i(11, 13), Vector2i(11, 14), Vector2i(11, 15), Vector2i(12, 0), Vector2i(12, 1), Vector2i(12, 2), Vector2i(12, 3), Vector2i(12, 4), Vector2i(12, 5), Vector2i(12, 6), Vector2i(12, 7), Vector2i(12, 8), Vector2i(12, 9), Vector2i(12, 10), Vector2i(12, 11), Vector2i(12, 12), Vector2i(12, 13), Vector2i(12, 14), Vector2i(12, 15), Vector2i(13, 0), Vector2i(13, 1), Vector2i(13, 2), Vector2i(13, 3), Vector2i(13, 4), Vector2i(13, 5), Vector2i(13, 6), Vector2i(13, 7), Vector2i(13, 8), Vector2i(13, 9), Vector2i(13, 10), Vector2i(13, 11), Vector2i(13, 12), Vector2i(13, 13), Vector2i(13, 14), Vector2i(13, 15), Vector2i(14, 0), Vector2i(14, 1), Vector2i(14, 2), Vector2i(14, 3), Vector2i(14, 4), Vector2i(14, 5), Vector2i(14, 6), Vector2i(14, 7), Vector2i(14, 8), Vector2i(14, 9), Vector2i(14, 10), Vector2i(14, 11), Vector2i(14, 12), Vector2i(14, 13), Vector2i(14, 14), Vector2i(14, 15), Vector2i(15, 0), Vector2i(15, 1), Vector2i(15, 2), Vector2i(15, 3), Vector2i(15, 4), Vector2i(15, 5), Vector2i(15, 6), Vector2i(15, 7), Vector2i(15, 8), Vector2i(15, 9), Vector2i(15, 10), Vector2i(15, 11), Vector2i(15, 12), Vector2i(15, 13), Vector2i(15, 14), Vector2i(15, 15)]
static func _vec2i_get_pos_in_chunk_opt16(chunkV:Vector2i) -> Array:
	var result := []
	for vec in OPT16_CHUNK:
		result.append(vec+chunkV)
	return result

static func vec2i_get_pos_in_chunk(chunkV:Vector2i, chunkSize:int) -> Array:
	if(chunkSize == 16):
		return _vec2i_get_pos_in_chunk_opt16(chunkV)
	var packedPositions := []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector2i(chunkV[0]*chunkSize + x, chunkV[1]*chunkSize + y))
	return packedPositions

static func vec3i_get_pos_in_chunk(chunkV:Vector3i, chunkSize:int) -> Array:
	var packedPositions := []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector3i(chunkV[0]*chunkSize + x, chunkV[1]*chunkSize + y, chunkV[2]))
	return packedPositions
