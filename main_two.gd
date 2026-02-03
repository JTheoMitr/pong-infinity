# res://Scripts/main_two.gd
extends Node2D

const game_over_sfx = preload("res://Assets/SFX/sfx_game_over.tscn")
const paddle_hit_sfx = preload("res://Assets/SFX/sfx_paddle_hit_1.tscn")

@onready var ball: CharacterBody2D = $Ball
@onready var paddle_left: StaticBody2D = $PaddleLeft
@onready var paddle_right: StaticBody2D = $PaddleRight
@onready var paddle_top: StaticBody2D = $PaddleTop
@onready var paddle_bottom: StaticBody2D = $PaddleBottom
@onready var corner_tl: StaticBody2D = $Corners/CornerTL
@onready var corner_tr: StaticBody2D = $Corners/CornerTR
@onready var corner_br: StaticBody2D = $Corners/CornerBR
@onready var corner_bl: StaticBody2D = $Corners/CornerBL

@onready var multi1_timer: Timer = $Multi1Timer

@onready var hud: CanvasLayer = $HUD
@onready var cam: Camera2D = $Camera2D
@onready var bgnd_layer_2: Sprite2D = $Sprite2D2
@onready var particles_root: Node2D = $Particles


@export var impact_particles_scene: PackedScene
@export var impact_particles_multiplier_1: PackedScene
@export var multiplier_1: PackedScene



var game_started: bool = false
var game_over_state: bool = false
var fade_up: bool = false
var fade_down: bool = true
var score := 0
var glow_time := 0.0



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	process_mode = Node.PROCESS_MODE_ALWAYS  # Allow input when paused
	hud.show_start_message("RICOCHET")
	hud.start_button_pressed.connect(_on_start_button_pressed)
	start_background_glow()
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	cam.enabled = true
	cam.position = screen_center
	reset_positions(screen_center)
	ball.visible = false
	
	await get_tree().create_timer(1.0).timeout
	spawn_impact_particles(get_viewport_rect().size * 2.5, Vector2.RIGHT)
	
	paddle_left.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_right.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_top.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_bottom.ball_hit_paddle.connect(_on_paddle_hit)
	corner_tl.ball_hit_paddle.connect(_on_paddle_hit)
	corner_tr.ball_hit_paddle.connect(_on_paddle_hit)
	corner_br.ball_hit_paddle.connect(_on_paddle_hit)
	corner_bl.ball_hit_paddle.connect(_on_paddle_hit)

	
	

func reset_positions(screen_center: Vector2) -> void:
	# Reset ball (CharacterBody2D)
	ball.global_position = screen_center
	ball.velocity = Vector2.ZERO
	ball.direction = Vector2.ZERO

	# Reset paddles
	paddle_left.reset_paddle()
	paddle_right.reset_paddle()
	paddle_top.reset_paddle()
	paddle_bottom.reset_paddle()



func _unhandled_input(event: InputEvent) -> void:
	# --- Start game with Space / Start button ---
	if not game_started and event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()

	# --- Pause / Unpause ---
	elif game_started and event.is_action_pressed("ui_pause"):
		toggle_pause()

	# --- Mobile tap pause: tap center third of screen ---
	elif game_started and event is InputEventScreenTouch and event.pressed:
		var screen_size := get_viewport_rect().size
		var third_x := screen_size.x / 3.0
		if event.position.x > third_x and event.position.x < third_x * 2:
			toggle_pause()
			print("pause by touch")
			
	elif event.is_action_pressed("ui_reset_paddles"):
		# Reset paddles
		paddle_left.reset_paddle()
		paddle_right.reset_paddle()
		paddle_top.reset_paddle()
		paddle_bottom.reset_paddle()
		


func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	hud.show_pause_overlay(get_tree().paused)
	print(ball.base_speed)


func _on_start_button_pressed() -> void:
	if game_over_state:
		print("game over")
		game_over_state = false
	hud.hide_start_message()
	hud.hide_score()
	ball.visible = true
	reset_score()
	multi1_timer.start()
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	reset_positions(screen_center)
	await countdown_and_start()


func countdown_and_start() -> void:
	for i in range(3, 0, -1):
		hud.show_countdown(i)
		await get_tree().create_timer(1.0).timeout
	hud.hide_countdown()

	# Wake the ball back up
	start_game()
	
func start_game() -> void:
	ball.base_speed = 400.0
	game_started = true
	ball.launch()


func game_over() -> void:
	game_started = false
	game_over_state = true
	var game_over_chime = game_over_sfx.instantiate()
	get_parent().add_child(game_over_chime)
	stop_all_timers()
	ball.velocity = Vector2.ZERO
	ball.direction = Vector2.ZERO
	hud.show_score()
	hud.show_start_message("Game Over - Click to Restart")

func _on_paddle_hit(paddle: Node) -> void:
	var paddle_bonk = paddle_hit_sfx.instantiate()
	get_parent().add_child(paddle_bonk)
	score += 15
	hud.update_score(score)
	ball.base_speed *= 1.01 #was 1.03
	print("paddle hit")
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles(ball.global_position, hit_dir)

func _on_corner_hit(paddle: Node) -> void:
	score += 5
	hud.update_score(score)
	ball.base_speed *= 1.01 #was 1.03
	print("corner hit")
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles(ball.global_position, hit_dir)

func _on_multiplier_hit(_multi: Node) -> void:
	score *= 2
	#audio here, smash sfx and words (multiplier!)
	hud.update_score(score)
	print("multi hit")
	# Spawn particles at impact
	spawn_impact_particles_multiplier1(ball.global_position)
	
	
func reset_score() -> void:
	score = 0
	hud.update_score(score)
	
func is_game_active() -> bool:
	return game_started


		
func start_background_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.95, 2.0)
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.10, 2.0)

func spawn_impact_particles(pos: Vector2, _dir_unused: Vector2) -> void:
	var p := impact_particles_scene.instantiate() as GPUParticles2D
	particles_root.add_child(p)

	var screen_center := get_viewport_rect().size * 0.5
	var to_center: Vector2 = (screen_center - pos).normalized()

	p.global_position = pos

	# 🔑 Godot 4 particles emit along -Y, so rotate by +90°
	p.global_rotation = to_center.angle() + PI / 2.0

	p.z_index = 100
	p.emitting = false
	p.emitting = true
	
func spawn_multi_1() -> void:
	var multi1 := multiplier_1.instantiate()
	multi1.ball_hit_multiplier_1.connect(_on_multiplier_hit)
	get_parent().add_child(multi1)
	var screen_size := get_viewport_rect().size
	var rndX = randf_range(0, screen_size.x)
	var rndY = randf_range(0, screen_size.y)
	multi1.global_position = Vector2(rndX, rndY)

func spawn_impact_particles_multiplier1(pos: Vector2) -> void:
	var p := impact_particles_multiplier_1.instantiate() as GPUParticles2D
	particles_root.add_child(p)
	p.global_position = pos

	p.z_index = 100
	p.emitting = false
	p.emitting = true


func _on_timer_timeout() -> void:
	spawn_multi_1()
	
func stop_all_timers() -> void:
	multi1_timer.stop()
	
#need a method to clear all buffs
#each buff: needs a spinning anim, an entry anim, and a shatter/break/disintegrate anim
#follow multi1 template on incorporating
	
