### ----------------------------------------------------
### Custom timer class
### ----------------------------------------------------

extends RefCounted
class_name STimer

### ----------------------------------------------------
### VARIABLES
### ----------------------------------------------------

# Time at which timer started
var startTime:int

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

func _init() -> void:
	start()

# get time stamp of start
func start() -> void:
	startTime = Time.get_ticks_msec()

# Returns time in ms from timer start
func get_result() -> int:
	return (Time.get_ticks_msec() - startTime)

# Answers if time in ms from start has passed
func time_passed(timeToPass:int) -> bool:
	return (get_result() > timeToPass)
