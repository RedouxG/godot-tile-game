### ----------------------------------------------------
# Save state for map editor
### ----------------------------------------------------

extends SMState

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:Node, name:String) -> void:
    super(caller, name)

func _state_set() -> void:
    Caller._show_lineEdit(Caller.UIElement.SaveInput)

func save_map(mapName:String) -> void:
    if(not Caller.editor_save_map(mapName)):
        Logger.log_err(["Failed to save: ", mapName])

func end_state() -> void:
    Caller._hide_lineEdit(Caller.UIElement.SaveInput)
    StateMaster.set_default_state()

func update_input(event:InputEvent) -> void:
    if(InputUtils.is_key_pressed(event, KEY_ESCAPE)):
        end_state()