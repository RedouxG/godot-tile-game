### ----------------------------------------------------
### Class for casting vision on a tilemap
### Source: http://www.roguebasin.com/index.php/FOV_using_recursive_shadowcasting#Shadowcasting
### ----------------------------------------------------

extends Script
class_name VisionCast

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const MULT := [
	[1,  0,  0, -1, -1,  0,  0,  1],
	[0,  1, -1,  0,  0, -1,  1,  0],
	[0,  1,  1,  0,  0, -1, -1,  0],
	[1,  0,  0,  1, -1,  0,  0, -1],
]

### ----------------------------------------------------
# Functions
### ----------------------------------------------------


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
	
	var xx:int = MULT[0][region]
	var xy:int = MULT[1][region]
	var yx:int = MULT[2][region]
	var yy:int = MULT[3][region]
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
