extends Control


func _on_play_button_button_up() -> void:
	BkMusic.click_bttn()
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")
