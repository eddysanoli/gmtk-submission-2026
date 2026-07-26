extends Control


func _on_play_button_button_up() -> void:
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")

func _on_credits_button_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
