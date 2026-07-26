extends Control

func _ready() -> void:
	pass 

func _on_button_button_up() -> void:
	$".".hide()
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")
