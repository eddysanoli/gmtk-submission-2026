extends Control


func _on_return_button_button_up():
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")
