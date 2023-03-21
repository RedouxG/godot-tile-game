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
func get_data() -> int:
	return (Time.get_ticks_msec() - startTime)

# Answers if time in ms from start has passed
func time_from_start(timeToPass:int) -> bool:
	return (get_data() > timeToPass)

func delay(timeMS:int) -> void:
	var s := Time.get_ticks_msec()
	var timePassed := 0
	while(timePassed < timeMS):
		timePassed = Time.get_ticks_msec() - s
