extends Area3D

var bread_speed = 10
var bread_damage = 10

func deal_damage():
	var enemy = get_overlapping_bodies()
	if enemy.is_in_group("Enemies"):
		enemy.take_damage(bread_damage)

func _process(delta):
	translate(Vector3.FORWARD * bread_speed * delta)
	

func _on_body_entered(_body):
	deal_damage()
	queue_free()
