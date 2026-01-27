# res://Scripts/main_two.gd
extends Node2D

@onready var ball: RigidBody2D = $Ball
@onready var paddle_left: StaticBody2D = $PaddleLeft
@onready var paddle_right: StaticBody2D = $PaddleRight
@onready var paddle_top: StaticBody2D = $PaddleTop
@onready var paddle_bottom: StaticBody2D = $PaddleBottom
@onready var hud: CanvasLayer = $HUD
@onready var cam: Camera2D = $Camera2D
@onready var bgnd_layer_2: Sprite2D = $Sprite2D2
@onready var particles_root: Node2D = $Particles


@export var impact_particles_scene: PackedScene



var game_started: bool = false
var game_over_state: bool = false
var fade_up: bool = false
var fade_down: bool = true
var score := 0
var glow_time := 0.0



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	process_mode = Node.PROCESS_MODE_ALWAYS  # Allow input when paused
	hud.show_start_message("PONG ∞")
	hud.start_button_pressed.connect(_on_start_button_pressed)
	start_background_glow()
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	cam.enabled = true
	cam.position = screen_center
	reset_positions(screen_center)
	ball.visible = false
	paddle_left.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_right.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_top.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_bottom.ball_hit_paddle.connect(_on_paddle_hit)
	await get_tree().create_timer(1.0).timeout
	spawn_impact_particles(get_viewport_rect().size * 0.5, Vector2.RIGHT)
	

func reset_positions(screen_center: Vector2) -> void:
	# Fully reset ball motion
	ball.sleeping = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.direction = Vector2.ZERO

	# Force physics engine to accept new transform
	var new_transform := ball.transform
	new_transform.origin = screen_center
	PhysicsServer2D.body_set_state(ball.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, new_transform)

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
	ball.sleeping = false
	start_game()
	
func start_game() -> void:
	ball.base_speed = 400.0
	game_started = true
	ball.launch()


func game_over() -> void:
	game_started = false
	game_over_state = true
	ball.linear_velocity = Vector2.ZERO
	hud.show_score()
	hud.show_start_message("Game Over - Click to Restart")

func _on_paddle_hit(paddle: Node) -> void:
	score += 1
	hud.update_score(score)
	ball.base_speed *= 1.01 #was 1.03
	
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles(ball.global_position, hit_dir)
	
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

func spawn_impact_particles(pos: Vector2, dir: Vector2) -> void:
	print("Spawning particles at:", pos)

	var p := impact_particles_scene.instantiate()
	print("Particle instance:", p)

	particles_root.add_child(p)
	print("Added to tree:", p.is_inside_tree())

	p.global_position = pos
	p.global_rotation = dir.angle()
	p.z_index = 100

	# 🔥 Critical Godot 4 sequence
	p.emitting = false
	p.emitting = true
