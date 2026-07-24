extends CharacterBody3D

@onready var spawn_location = $Position3D
@onready var cooldown_timer = $Cooldown
@onready var bread = preload("res://scenes/bread.tscn")

const SPEED = 5.0

var charging = false
var can_shoot = true
var dead = false

func _ready():
	pass
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
	
func _process(_delta):
	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("Pause"):
		pause()
	
func _physics_process(_delta: float) -> void:
	if dead:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func shoot():
	if !can_shoot:
		return
	var new_bread = bread.instantiate()
	get_node("../Enviorment").add_child(new_bread)
	new_bread.global_transform = spawn_location.global_transform
	can_shoot = false
	cooldown_timer.start()

func pause():
	get_tree().paused = true
	$CanvasLayer/PauseScreen.show()

func _on_cooldown_timeout():
	can_shoot = true

func _on_return_button_up():
	$CanvasLayer/PauseScreen.hide()
	get_tree().paused = false
