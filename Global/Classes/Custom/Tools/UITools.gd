### ----------------------------------------------------
### Extends on input functions
### ----------------------------------------------------

extends Script
class_name UITools

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

# Tells if mouse is on UI (Control node) element
static func is_mouse_on_ui(element:Control, parentElement:Control) -> bool:
	return element.get_rect().has_point(parentElement.get_local_mouse_position())
