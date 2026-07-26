extends StaticBody3D

func interact():
	print("Yay, you win")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/end_game.tscn")
