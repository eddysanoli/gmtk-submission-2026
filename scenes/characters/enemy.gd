extends CharacterBody3D

@export var move_speed = 1.0
@export var attack_range = 2.0
@export var health = 30.0
@export var memory_time = 5.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
var dead = false

# ───────────────────Behaviour Variables──────────────────────────
enum State {
	IDLE,
	CHASE,
	ATTACK
}

var state = State.IDLE
var last_seen_position = Vector3.ZERO
var lose_sight_timer = 0.0
# ─────────────────────────────────────────────

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	match state:
		State.IDLE:
			if can_see_player():
				state = State.CHASE
				last_seen_position = player.global_position
		State.CHASE:
			chase_player(delta)
		State.ATTACK:
			attempt_to_kill_player()
	
# ───────────────Player Interaction──────────────────────
func can_see_player() -> bool:
	var eye = Vector3.UP * 1.5

	var query = PhysicsRayQueryParameters3D.create(
		global_position + eye,
		player.global_position + eye
	)
	query.exclude = [self]
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	return result.has("collider") and result.collider == player
	
func chase_player(delta):
	if can_see_player():
		last_seen_position = player.global_position
		lose_sight_timer = memory_time
	else:
		lose_sight_timer -= delta
		if lose_sight_timer <= 0:
			state = State.IDLE
			return
	var dir = last_seen_position - global_position
	dir.y = 0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < attack_range:
		state = State.ATTACK

func attempt_to_kill_player():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player.kill()

# ────────────────────Damage─────────────────────────
func take_damage(damage):
	health -= damage
	if health <= 0:
		kill()

func kill():
	dead = true
	$CollisionShape3D.disabled = true
	hide()
