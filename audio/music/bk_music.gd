extends Control

var dead_music = true

func _ready():
	$BKMusic.play()
	
func click_bttn():
	$Click.play()
	
func dead():
	if dead_music:
		print("music")
		$ImDead.play()
		dead_music = false
