extends Control

func _on_return_button_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/instructions.tscn")
