extends Node3D

@onready var sun_light: DirectionalLight3D = $Sky3D/SunLight
var hue:float = 0.0

func _physics_process(delta):
	hue = fmod(hue + (delta * 0.5), 1.0)
	sun_light.set_color(Color.from_hsv(hue,1.0,1.0))
