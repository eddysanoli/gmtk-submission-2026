extends CharacterBody3D

# ─────────────────────────────────────────────
@onready var spawn_location = $Position3D
@onready var cooldown_timer = $Cooldown
@onready var charge_timer = $Charge
@onready var bread = preload("res://scenes/bread.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var interaction_raycast: RayCast3D = $RayCast3D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $CanvasLayer/GunBase/AnimatedSprite2D2
@onready var timer_clock: AnimatedSprite2D = $CanvasLayer/GunBase/AnimatedSprite2D3
@onready var countdown: Label = $CanvasLayer/GunBase/Label
@onready var countdown_timer: Timer = $countdown_timer

# ─────────────────────────────────────────────
const SPEED = 5.0
const FADE_AT_COUNT = 5
const START_COUNT = 8

var charging = false
var charge_start_time: float
var charge_tier = 0
var charge_timeout = false
var can_shoot = false
var dead = false

var counting = START_COUNT
var fade_tween: Tween

var interaction_is_reset: bool = true

# ─────────────────────────────────────────────
func _ready():
	animated_sprite_2d.play("start")
	Engine.time_scale = 1
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	BkMusic.dead_music = true
	
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion and Engine.time_scale != 0:
		rotation_degrees.y -= event.relative.x * 0.5
	if event.is_action_pressed("interact"):
		if interaction_raycast.is_colliding():
			var interactable = interaction_raycast.get_collider()
			if interactable.has_method("interact"):
				interactable.interact()

# ─────────────────────────────────────────────
func _process(_delta):
	if dead:
		return
	if Input.is_action_just_pressed("Pause"):
		pause()
	if interaction_raycast.is_colliding():
		var interactable = interaction_raycast.get_collider()
		interaction_is_reset = false
		if interactable != null and interactable.has_method("interact"):
			$CanvasLayer/Interact.show()
	else:
		if !interaction_is_reset:
			$CanvasLayer/Interact.hide()
			interaction_is_reset = true
	if !charging and Engine.time_scale != 0 and can_shoot:
		charging = true
		charge_timer.start()
		show_countdown()
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
	
func show_countdown():
	if fade_tween:
		fade_tween.kill()
	countdown_timer.stop()
	counting = START_COUNT
	countdown_timer.start()
	timer_clock.modulate.a = 1.0
	timer_clock.show()
	timer_clock.play("default")
	countdown.modulate.a = 1.0
	countdown.text = str(counting)
	countdown.show()

func shoot(charge_start: float, charge_end: float):
	calculate_power(charge_end - charge_start)
	if charge_tier != 0:
		animated_sprite_2d.play("shoot")
		await get_tree().create_timer(0.4).timeout
		$Recharge.play()
		await get_tree().create_timer(0.5).timeout
		var new_bread = bread.instantiate()
		new_bread.charge_power = charge_tier
		get_node("../Objects").add_child(new_bread)
		new_bread.global_transform = spawn_location.global_transform
		cooldown_timer.start()
	if charge_tier == 0:
		$Explosion.play()
		animated_sprite_2d_2.play("default")
		cooldown_timer.start()
	
func calculate_power(charging_time):
	var charge = floor(charging_time / 1000)
	print(charge)
	if charging_time < 9000:
		charge_tier = charge + 1
	if charging_time >= 9000:
		charge_tier = 0

func _on_cooldown_timeout():
	can_shoot = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "start":
		can_shoot = true
		animated_sprite_2d.play("idle")
	if animated_sprite_2d.animation == "shoot":
		animated_sprite_2d.play("idle")
		
func fade_out_countdown() -> void:
	timer_clock.stop()
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(timer_clock, "modulate:a", 0.0, 0.5)
	fade_tween.tween_property(countdown, "modulate:a", 0.0, 0.5)
	fade_tween.chain().tween_callback(func():
		timer_clock.hide()
		countdown.hide()
	)

# ────────────────────PAUSE─────────────────────────
func pause():
	Engine.time_scale = 0
	charging = false
	$Pause.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/PauseScreen.show()

func _on_return_button_up():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/PauseScreen.hide()
	Engine.time_scale = 1
	$Click.play()
	
func _on_quit_button_up():
	Engine.time_scale = 1
	$CanvasLayer.hide()
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")
	$Click.play()

# ────────────────────DEATH─────────────────────────
func kill():
	Engine.time_scale = 0
	dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/GunBase.hide()
	$CanvasLayer/DeathScreen.show()
	BkMusic.dead()

func _on_restart_button_up():
	#get_tree().change_scene_to_file("res://scenes/enviorment/stage.tscn")
	$CanvasLayer.hide()
	$Click.play()
	game_manager.load_scene_with_loading_screen("res://scenes/enviorment/stage.tscn")
	

func _on_quit_game_button_up() -> void:
	#get_tree().change_scene_to_file("res://scenes/menu.tscn")
	$CanvasLayer.hide()
	$Click.play()
	game_manager.load_scene_with_loading_screen("res://scenes/menu.tscn")
	
	
func _on_countdown_timer_timeout() -> void:
	counting -= 1
	countdown.text = str(counting)
	if counting <= FADE_AT_COUNT:
		fade_out_countdown()
	else:
		countdown_timer.start()
