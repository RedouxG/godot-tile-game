### ----------------------------------------------------
### Extends on input Functions
### ----------------------------------------------------

extends Script
class_name InputUtils

### ----------------------------------------------------
### Functions
### ----------------------------------------------------

# SHOULD NOT BE USED IN GAME - physical keys vary between keyboards
static func is_key_pressed(event:InputEvent, keyCode:int) -> bool:
    if(not event is InputEventKey):
        return false
    if(event.physical_keycode == keyCode and not event.echo and event.pressed):
        return true
    return false
