extends CharacterBody3D

# ─────────────────────────────────────────────
@onready var spawn_location = $Position3D
@onready var cooldown_timer = $Cooldown
@onready var charge_timer = $Charge
@onready var bread = preload("res://scenes/bread.tscn")

# ─────────────────────────────────────────────
const SPEED = 5.0

var charging = false
var charge_start_time : float
var charge_tier = 0
var charge_timeout = false
var can_shoot = true
var dead = false

# ─────────────────────────────────────────────
func _ready():
	Engine.time_scale = 1
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion and Engine.time_scale != 0:
		rotation_degrees.y -= event.relative.x * 0.5

# ─────────────────────────────────────────────
func _process(_delta):
	if dead:
		return
	if Input.is_action_just_pressed("Pause"):
		pause()
	if !charging and Engine.time_scale != 0 and can_shoot:
		charging = true
		charge_timer.start()
		charge_start_time = Time.get_ticks_msec()
	if charging == true:
		if Input.is_action_just_pressed("shoot") or charge_timeout == true:
			charging = false
			can_shoot = false
			charge_timeout = false
			shoot(charge_start_time, Time.get_ticks_msec())
	
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
func _on_charge_timeout():
	if !can_shoot:
		return
	charge_timeout = true
	
func shoot(charge_start: float, charge_end: float):
	calculate_power(charge_end-charge_start)
	var new_bread = bread.instantiate()
	new_bread.charge_power = charge_tier
	get_node("../Objects").add_child(new_bread)
	new_bread.global_transform = spawn_location.global_transform
	cooldown_timer.start()
	
func calculate_power(charging_time):
	var charge = floor(charging_time/1000)
	print(charge)
	if charging_time < 9000:
		charge_tier = charge + 1
	if charging_time >= 9000:
		charge_tier = 0

func _on_cooldown_timeout():
	can_shoot = true

# ────────────────────PAUSE─────────────────────────
func pause():
	Engine.time_scale = 0
	charging = false
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
	Engine.time_scale = 0
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/DeathScreen.show()

func _on_restart_button_up():
	$CanvasLayer.hide()
	Engine.time_scale = 1
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")

func _on_quit_game_button_up() -> void:
	$CanvasLayer.hide()
	Engine.time_scale = 1
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")
	
