### ----------------------------------------------------
### Manages multiple inputs
### ----------------------------------------------------

extends RefCounted
class_name InputHandler

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var _delayTimeMS:int
var DelayTimer := STimer.new()

var _FuctionDict := {}

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(delayTimeMS:int) -> void:
	_delayTimeMS = delayTimeMS

func add_function(key:Variant, function:Callable) -> void:
	_FuctionDict[key] = function

func handle_input_keycode(event:InputEvent) -> void:
	if(not DelayTimer.time_passed(_delayTimeMS)):
		return
	if(not event is InputEventKey):
		return
	if(event.echo and not event.pressed):
		return
	if(not _FuctionDict.get(event.physical_keycode) is Callable):
		return
	
	_FuctionDict[event.physical_keycode].call()
	DelayTimer.start()
