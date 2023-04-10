### ----------------------------------------------------
### Sublib for scene related tasks
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func pack_to_scene(node:Node) -> PackedScene:
	var scene := PackedScene.new()
	scene.pack(node)
	return scene
