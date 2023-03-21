### ----------------------------------------------------
### Controls camera movement in the editor
### Key inputs:
### 	WASD         - Move in a direction by 16 pixels
### 	Shift + WASD - Move in a direction faster
### 	Scroll Up    - Zoom camera out
### 	Scroll Down  - Zoom camera in
### 	-            - Minus elevation
### 	=            - Add elevation
### ----------------------------------------------------

extends Camera2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var zoomValue:float = 0.05
var currentElevation:int = 0
var inputActive:bool = true

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Input
### ----------------------------------------------------
func zoom_camera(value:float):
	if zoom[0] + value < 0.1: return
	if zoom[0] + value > 1:   return
	
	zoom = Vector2(zoom[0]+value, zoom[1]+value)
### ----------------------------------------------------
