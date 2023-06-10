### ----------------------------------------------------
### Extends on input functions
### ----------------------------------------------------

extends Script
class_name UIUtils

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------

# Tells if mouse is on UI (Control node) element
static func is_mouse_on_ui(element:Control) -> bool:
	return element.get_global_rect().has_point(element.get_global_mouse_position())
