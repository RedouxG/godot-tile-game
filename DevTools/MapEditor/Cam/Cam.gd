### ----------------------------------------------------
### Controls camera movement in the editor
### Key inputs:
###     WASD         - Move in a direction by 16 pixels
###     Shift + WASD - Move in a direction faster
###     Scroll Up    - Zoom camera out
###     Scroll Down  - Zoom camera in
###     -            - Minus elevation
###     =            - Add elevation
### ----------------------------------------------------

extends Camera2D

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const MAX_ZOOM = 8.0
const MIN_ZOOM = 1.0
var zoomValue:float = 0.05

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func zoom_camera(value:float):
    if zoom[0] + value < MIN_ZOOM: return
    if zoom[0] + value > MAX_ZOOM: return
    zoom = Vector2(zoom[0]+value, zoom[1]+value)
