### ----------------------------------------------------
### Template state, every state in inherited Statemachine should have these Functions
### ----------------------------------------------------

extends RefCounted
class_name SMState

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

# Caller aka StateMachine source class
var Caller:Node

# Parent state machine, reference used for switching states inside of a given state
var StateMaster

var Name:String = "Unnamed State"

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

# Automatically assigns Variables in State to Variables in parent (by reference)
func _init(caller:Node, name:String) -> void:
	Name = name
	Caller = caller

# Called whenever a state is set as current by StateMachine
func _state_set() -> void:
	pass

# Set of instructions executed at the end of state, can be overwritten
func end_state() -> void:
	StateMaster.set_default_state()

# Returns name of a state
func get_name() -> String:
	return Name

# For physics process
func update_delta(_delta:float) -> void:
	Logger.log_err(["Function should be overwriten! "])

# For input event
func update_input(_event:InputEvent) -> void:
	Logger.log_err(["Function should be overwriten! "])

func _to_string() -> String:
	return get_name()