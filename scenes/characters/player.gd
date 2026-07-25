extends CharacterBody3D

# ─────────────────────────────────────────────
@onready var spawn_location = $Position3D
@onready var cooldown_timer = $Cooldown
@onready var bread = preload("res://scenes/bread.tscn")

# ─────────────────────────────────────────────
const SPEED = 5.0

var charging = false
var charge_start_time : float
var charge_tier = 0
var can_shoot = true
var dead = false

# ─────────────────────────────────────────────
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5

# ─────────────────────────────────────────────
func _process(_delta):
	if dead:
		return
	if (Input.is_action_just_pressed("shoot")) and (Engine.time_scale != 0):
		if !can_shoot:
			return
		charging = true
		charge_start_time = Time.get_ticks_msec()
	if Input.is_action_just_released("shoot") and charging == true:
		charging = false
		shoot(charge_start_time, Time.get_ticks_msec())
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

# ─────────────────────SHOOTING────────────────────────
func shoot(charge_start: float, charge_end: float):
	calculate_power(charge_end-charge_start)
	var new_bread = bread.instantiate()
	new_bread.power_tier = charge_tier
	get_node("../Objects").add_child(new_bread)
	new_bread.global_transform = spawn_location.global_transform
	can_shoot = false
	cooldown_timer.start()
	
func calculate_power(charging_time):
	if charging_time < 500:
		charge_tier = 1
	if charging_time > 500 and charging_time < 1500:
		charge_tier = 2
	if charging_time > 1500:
		charge_tier = 3

func _on_cooldown_timeout():
	can_shoot = true

# ────────────────────PAUSE─────────────────────────
func pause():
	Engine.time_scale = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/PauseScreen.show()

func _on_return_button_up():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/PauseScreen.hide()
	Engine.time_scale = 1
	
func _on_quit_button_up():
	Engine.time_scale = 1
	$CanvasLayer/PauseScreen.hide()
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")

# ────────────────────DEATH─────────────────────────
func kill():
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/DeathScreen.show()

func _on_restart_button_up():
	$CanvasLayer.hide()
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")

func _on_quit_game_button_up():
	$CanvasLayer.hide()
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")
	
