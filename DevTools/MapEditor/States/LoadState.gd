### ----------------------------------------------------
# Load state for map editor
### ----------------------------------------------------

extends SMState

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

func _init(caller:Node, name:String) -> void:
    super(caller, name)

func _state_set() -> void:
    Caller._show_lineEdit(Caller.UIElement.LoadInput)

func load_map(mapName:String) -> void:
    var Temp := SQLSave.new(mapName, SAVE_MANAGER.TEMP_FOLDER)
    if(not Caller.editor_load_map(mapName)):
        Logger.log_err(["Failed to load: ", mapName])
    Caller.TM.refresh_all_chunks()
    
func end_state() -> void:
    Caller.get_node("TileMapManager").unload_all()
    Caller._hide_lineEdit(Caller.UIElement.LoadInput)
    StateMaster.set_default_state()

func update_input(event:InputEvent) -> void:
    if(InputUtils.is_key_pressed(event, KEY_ESCAPE)):
        end_state()