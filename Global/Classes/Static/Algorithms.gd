### ----------------------------------------------------
### Handles formatting numbers to readable string
### ----------------------------------------------------

extends Script
class_name Algorithms

### ----------------------------------------------------
### Variables
### ----------------------------------------------------

const INT_MAX:int = 9223372036854775807
const INT_MIN:int = -9223372036854775807

const _VISION_MULTIPLICATION_MATRIX := [
	[1,  0,  0, -1, -1,  0,  0,  1],
	[0,  1, -1,  0,  0, -1,  1,  0],
	[0,  1,  1,  0,  0, -1, -1,  0],
	[1,  0,  0,  1, -1,  0,  0, -1],
]

### ----------------------------------------------------
### Scripts
### ----------------------------------------------------

# Compresses string and saves bytes as base64 string
static func compress_str(Str:String, CMode:int) -> String:
	var B64Str := Marshalls.utf8_to_base64(Str)
	return Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64Str).compress(CMode))

# Decompresses string
static func decompress_str(B64C:String, CMode:int, DCSize:int) -> String:
	var B64DC := Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64C).decompress(DCSize,CMode))
	return Marshalls.base64_to_utf8(B64DC)

# WallMap { pos:isTransparent }
static func get_visible_points(vantagePoint:Vector2, WallMap:Dictionary, maxDistance:int = 30) -> Array:
	var losCache:Array[Vector2] = [vantagePoint]
	for region in range(8):
		_cast_light(losCache, WallMap, vantagePoint.x, vantagePoint.y, 1,
		1.0, 0.0, maxDistance, region)
	return losCache

static func _cast_light(losCache:Array[Vector2], WallMap:Dictionary, cx:float, cy:float, row:int, 
	start:float, end:float, radius:int, region:int) -> void:
	if(start < end): return
	
	var xx:int = _VISION_MULTIPLICATION_MATRIX[0][region]
	var xy:int = _VISION_MULTIPLICATION_MATRIX[1][region]
	var yx:int = _VISION_MULTIPLICATION_MATRIX[2][region]
	var yy:int = _VISION_MULTIPLICATION_MATRIX[3][region]
	var radius_squared := radius*radius
	
	for j in range(row, radius+1):
		var dx := -j-1
		var dy := -j
		var blocked := false
		var new_start := start

		while(dx <= 0):
			dx += 1
			# Translate the dx, dy coordinates into map coordinates:
			var X:float = cx + dx * xx + dy * xy
			var Y:float = cy + dx * yx + dy * yy
			var point := Vector2(X, Y)
			
			# l_slope and r_slope store the slopes of the left and right
			# extremities of the square we're considering:
			var l_slope:float = (dx-0.5)/(dy+0.5)
			var r_slope:float = (dx+0.5)/(dy-0.5)
			
			if (start < r_slope): continue
			elif (end > l_slope): break
			
			# Our light beam is touching this square; light it:
			if(dx*dx + dy*dy < radius_squared):
				losCache.append(point)
			
			if blocked:
				# we're scanning a row of blocked squares:
				if(not WallMap.get(point)): 
					new_start = r_slope
					continue
				else:
					blocked = false
					start = new_start
			else:
				if((not WallMap.get(point)) and (j < radius)):
					# This is a blocking square, start a child scan:
					blocked = true
					_cast_light(losCache, WallMap, cx, cy, j+1, start, l_slope, radius, region)
					new_start = r_slope
		# Row is scanned; do next row unless last square was blocked:
		if(blocked): break

# Format string example:
# 120s -> "hh:mm:ss" -> 00:02:00 
static func seconds_to_time(seconds:int, format:String) -> String:
	var hours:int = int(float(seconds) / 3600)
	var minutes:int = int(float((seconds - hours * 3600)) / 60)
	seconds = seconds - (hours * 3600) - (minutes*60)
	format = format.to_lower()
	format = format.replace("hh", num_to_str_trim(hours, 2))
	format = format.replace("mm", num_to_str_trim(minutes, 2))
	format = format.replace("ss", num_to_str_trim(seconds, 2))
	return format

static func num_to_str_trim(number:int, trimLen:int) -> String:
	var result := str(number)
	while(result.length() < trimLen):
		result = "0" + result
	if(result.length() > trimLen):
		result = result.substr(0, trimLen)
	return result

static func clamp_increment_int(value:int, minNum:int, maxNum:int) -> int:
	value += 1
	if(value > maxNum):
		value = minNum
	return value

static func clamp_decrement_int(value:int, minNum:int, maxNum:int) -> int:
	value -= 1
	if(value < minNum):
		value = maxNum
	return value
