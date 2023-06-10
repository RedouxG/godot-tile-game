### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends SMState
class_name PlayerMove

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

const MOVE_UU = Vector2.UP
const MOVE_DD = Vector2.DOWN
const MOVE_LL = Vector2.LEFT
const MOVE_RR = Vector2.RIGHT
const MOVE_UR = MOVE_UU + MOVE_RR
const MOVE_UL = MOVE_UU + MOVE_LL
const MOVE_DR = MOVE_DD + MOVE_RR
const MOVE_DL = MOVE_DD + MOVE_LL

signal PlayerMoved(posV2)

const INPUT_COOLDOWN := 150
var InputDelayer := STimer.new()

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:Node2D, name:String) -> void:
	super(caller, name)

func move_player(direction:Vector2i) -> void:
	if(not InputDelayer.time_from_start(INPUT_COOLDOWN)):
		return
	
	Caller.MapPosition += VectorUtilsExt.vec2i_vec3i(
		direction * GLOBAL.TILEMAPS.BASE_SCALE, 0)
	emit_signal("PlayerMoved", VectorUtilsExt.vec3i_vec2i(Caller.MapPosition))
	InputDelayer.start()

func update_input(_event:InputEvent) -> void:
	pass

func update_delta(_delta:float) -> void:
	if(Input.is_action_pressed("DownR")):
		move_player(MOVE_DR)
	elif(Input.is_action_pressed("DownL")):
		move_player(MOVE_DL)
	elif(Input.is_action_pressed("UpR")):
		move_player(MOVE_UR)
	elif(Input.is_action_pressed("UpL")):
		move_player(MOVE_UL)
	elif(Input.is_action_pressed("Left")):
		move_player(MOVE_LL)
	elif(Input.is_action_pressed("Right")):
		move_player(MOVE_RR)
	elif(Input.is_action_pressed("Up")):
		move_player(MOVE_UU)
	elif(Input.is_action_pressed("Down")):
		move_player(MOVE_DD)
