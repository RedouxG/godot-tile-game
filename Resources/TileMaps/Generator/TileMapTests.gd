@tool
extends EditorScript

const TERRAIN_PATH = "res://Resources/TileMaps/Generator/TerrainTemplate/"
const TS := preload(TERRAIN_PATH + "TS.tres")


	

func _run() -> void:
	for source in LibK.TS.get_sources(TS):
		print(LibK.TS.get_tileIDs_and_alts(source))
