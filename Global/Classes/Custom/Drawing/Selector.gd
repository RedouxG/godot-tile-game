### ----------------------------------------------------
### 
### ----------------------------------------------------

extends RefCounted
class_name Selector

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var Caller:DrawNode
var StartingPos:Vector2i

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:DrawNode) -> void:
    Caller = caller

func set_StartingPos(pos:Vector2i) -> void:
    StartingPos = pos

func draw_selected_area(pos:Vector2i, color:Color = Color.RED, fill:bool = false, width:float = 1.0) -> void:
    var rect := Rect2i(StartingPos, pos)
    Caller.add_function_to_DrawQueue(Callable(Caller, "draw_rect").bindv([rect, color, fill, width]))