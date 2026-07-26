extends Control

func _on_button_button_up():
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")
	BkMusic.click_bttn()
	

func _on_credits_button_button_up():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
	BkMusic.click_bttn()
