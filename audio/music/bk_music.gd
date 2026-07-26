extends Control


func _ready():
	print("music")
	$BKMusic.play()
	
func click_bttn():
	$Click.play()
	
func dead():
	$ImDead.play()
