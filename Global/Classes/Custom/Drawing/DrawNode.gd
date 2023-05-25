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