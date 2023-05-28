### ----------------------------------------------------
# Filter state for map editor
### ----------------------------------------------------

extends SMState

### ----------------------------------------------------
# Variables
### ----------------------------------------------------

var filter := ""

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:Node, name:String) -> void:
    super(caller, name)

func _state_set() -> void:
    Caller._show_lineEdit(Caller.UIElement.FilterInput)

func change_filter(new_text:String) -> void:
    filter = new_text
    Caller.UIElement.FilterInput.text = "FilterInput: " + "\"" + filter + "\""

func end_state() -> void:
    Caller._hide_lineEdit(Caller.UIElement.FilterInput)
    StateMaster.set_default_state()

func update_input(event:InputEvent) -> void:
    if(InputTools.is_key_pressed(event, KEY_ESCAPE)):
        end_state()