### ----------------------------------------------------
# Go to state for map editor
### ----------------------------------------------------

extends SMState

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:Node, name:String) -> void:
    super(caller, name)

func _state_set() -> void:
    Caller._show_lineEdit(Caller.UIElement.GotoInput)

func change_coords(new_text:String) -> void:
    var coords:Array = new_text.split(" ")
    if(not coords.size() >= 2): 
        return
    if(not coords[0].is_valid_int() and coords[1].is_valid_int()):
        return
    
    Caller.get_node("Cam").global_position = Vector2(
        int(coords[0]) * GLOBAL.TILEMAPS.BASE_SCALE,
        int(coords[1]) * GLOBAL.TILEMAPS.BASE_SCALE)

func end_state() -> void:
    Caller._hide_lineEdit(Caller.UIElement.GotoInput)
    StateMaster.set_default_state()

func update_input(event:InputEvent) -> void:
    if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
        end_state()