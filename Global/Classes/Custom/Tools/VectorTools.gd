### ----------------------------------------------------
### Wrapper around godot built in TileMap
### ----------------------------------------------------

extends Script
class_name VectorTools

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func vec3i_get_range_2d(atPos:Vector3i, squareRange:int) -> Array[Vector3i]:
	var result:Array[Vector3i] = []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			result.append(Vector3i(x,y,0) + atPos)
	return result

static func vec3i_get_range_3d(atPos:Vector3i, squareRange:int) -> Array[Vector3i]:
	var result:Array[Vector3i] = []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			for z in range(-squareRange, squareRange + 1):
				result.append(Vector3i(x,y,z) + atPos)
	return result

# precomputedArr is vec3i_get_range_Nd array at pos 0,0,0 of a given size
static func vec3i_get_precomputed_range(atPos:Vector3i, precomputedArr:Array[Vector3i]) -> Array[Vector3i]:
	var arrcopy := precomputedArr.duplicate()
	for index in arrcopy.size():
		arrcopy[index] += atPos
	return arrcopy

static func vec2i_get_range(atPos:Vector2i, squareRange:int) -> Array[Vector2i]:
	var result:Array[Vector2i] = []
	for x in range(-squareRange, squareRange + 1):
		for y in range(-squareRange, squareRange + 1):
			result.append(Vector2i(x,y) + atPos)
	return result

# precomputedArr is vec2i_get_range array at pos 0,0 of a given size
static func vec2i_get_precomputed_range(atPos:Vector2i, precomputedArr:Array[Vector2i]) -> Array[Vector2i]:
	var arrcopy := precomputedArr.duplicate()
	for index in arrcopy.size():
		arrcopy[index] += atPos
	return arrcopy
	
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

static func scale_down_vec2i(v:Vector2, scale:int) -> Vector2i:
	v/=scale
	return Vector2i(v.floor())

static func scale_down_vec3i(v:Vector3, scale:int) -> Vector3i:
	v/=scale
	return Vector3i(v.floor())

static func scale_down_vec3i_noZ(v:Vector3, scale:int) -> Vector3i:
	return Vector3i(Vector3(v[0]/scale, v[1]/scale, v[2]).floor())

static func vec2i_get_pos_in_chunk(chunkV:Vector2i, chunkSize:int) -> Array[Vector2i]:
	var packedPositions :Array[Vector2i] = []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector2i(chunkV[0]*chunkSize + x, chunkV[1]*chunkSize + y))
	return packedPositions

# precomputedArr is vec2i_get_pos_in_chunk array at pos 0,0 of a given size
static func vec2i_get_precomputed_pos_in_chunk(chunk:Vector2i, precomputedArr:Array[Vector2i]) -> Array[Vector2i]:
	var arrcopy := precomputedArr.duplicate()
	var arrSize:int = int(sqrt(arrcopy.size()))
	for index in arrcopy.size():
		arrcopy[index] += chunk * arrSize
	return arrcopy

static func vec3i_get_pos_in_chunk(chunkV:Vector3i, chunkSize:int) -> Array[Vector3i]:
	var packedPositions :Array[Vector3i] = []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector3i(chunkV[0]*chunkSize + x, chunkV[1]*chunkSize + y, chunkV[2]))
	return packedPositions

# precomputedArr is vec3i_get_pos_in_chunk array at pos 0,0 of a given size
static func vec3i_get_precomputed_pos_in_chunk(chunk:Vector3i, precomputedArr:Array[Vector3i]) -> Array[Vector3i]:
	var arrcopy := precomputedArr.duplicate()
	var arrSize:int = int(sqrt(arrcopy.size()))
	for index in arrcopy.size():
		arrcopy[index] += chunk * arrSize
	return arrcopy
