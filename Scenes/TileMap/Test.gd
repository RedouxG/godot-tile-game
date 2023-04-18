extends TileMap

func _ready() -> void:
	set_cells_terrain_connect(0, [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2)], 0, 0)
	var TD := get_cell_tile_data(0, Vector2i(0,0))
	
	print(TD.terrain)
	print(TD.terrain_set)
