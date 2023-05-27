### ----------------------------------------------------
### Base class for all nodes that want to use specific drawing utilities
### Allows for adding draw items from any place in the code
### ----------------------------------------------------

extends Node2D
class_name DrawNode

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

# List of Functions that will be called 
var _DrawQueue:Array[Callable] = []

### ----------------------------------------------------
# Class
### ----------------------------------------------------

class Selector extends RefCounted:
    var _color:Color
    var _fill:bool
    var _width:float

    var Caller:DrawNode
    var StartingPos:Vector2i
    var isActive := false
    
    func _init(caller:DrawNode, color:Color = Color.RED, fill:bool = false, width:float = 1.0) -> void:
        Caller = caller
        _color = color
        _fill = fill
        _width = width

    func start(startPos:Vector2i) -> void:
        StartingPos = startPos
        isActive = true

    func draw_selected_area(pos:Vector2i) -> void:
        var rect := Rect2i(StartingPos, pos - StartingPos)
        Caller.add_function_to_DrawQueue(Callable(Caller, "draw_rect").bindv([rect, _color, _fill, _width]))
    
    func end() -> void:
        isActive = false
    
    func get_positions_in_selected(pos:Vector2i, chunkSize:int) -> Array[Vector2i]:
        
        return []


### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func add_function_to_DrawQueue(function:Callable) -> void:
    _DrawQueue.append(function)

# Function must be called in _draw()
func draw_items_in_DrawQueue() -> void:
    for index in range(_DrawQueue.size()):
        _DrawQueue[index].call()
    _DrawQueue.clear()

func _draw():
    draw_items_in_DrawQueue()