extends Node


func load_scene_with_loading_screen(path_to_scene:String):
	var loading_screen = preload("res://scenes/loading_screen.tscn").instantiate()
	get_tree().root.add_child(loading_screen)
	loading_screen.start_loading_scene(path_to_scene)
	
