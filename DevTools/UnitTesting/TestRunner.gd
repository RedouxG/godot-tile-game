extends Control

func _ready() -> void:
	print(Engine.get_main_loop())
	var node = Node2D.new()
	node.set_script(load("res://addons/gut/gut.gd"))
	add_child(node)
