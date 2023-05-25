### ----------------------------------------------------
### Manages multiple inputs
### ----------------------------------------------------

extends RefCounted
class_name InputHandler

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var _FuctionDict:Dictionary = {}
### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func add_function(key:Variant, function:Callable) -> void:
	_FuctionDict[key] = function

func handle_input_keycode(event:InputEvent) -> void:
	if(not event is InputEventKey):
		return
	if(event.echo and not event.pressed):
		return
	if(not _FuctionDict.get(event.physical_keycode) is Callable):
		return
	_FuctionDict[event.physical_keycode].call()
