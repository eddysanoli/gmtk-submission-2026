extends Area3D

# ─────────────────────────────────────────────
var power_tier = 1
var bread_speed = 10
var bread_damage = 10

# ─────────────────────────────────────────────
func _ready():
	bread_damage = 10*power_tier
	print("power_tier =", power_tier)
	print("bread_damage =", bread_damage)


func deal_damage():
	var enemy = get_overlapping_bodies()
	if enemy.is_in_group("Enemies"):
		enemy.take_damage(bread_damage)

# ─────────────────────────────────────────────
func _process(delta):
	translate(Vector3.FORWARD * bread_speed * delta)
	

func _on_body_entered(body):
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(bread_damage)
	queue_free()
