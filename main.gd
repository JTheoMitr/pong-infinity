# res://Scripts/main.gd
extends Node2D

@onready var ball: RigidBody2D = $Ball
@onready var paddle_left: StaticBody2D = $PaddleLeft
@onready var paddle_right: StaticBody2D = $PaddleRight
@onready var hud: CanvasLayer = $HUD
@onready var cam: Camera2D = $Camera2D

var game_started: bool = false
var game_over_state: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_start_message("Start Game")
	hud.start_button_pressed.connect(_on_start_button_pressed)

	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	cam.enabled = true
	cam.position = screen_center
	reset_positions(screen_center)


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
	paddle_left.position = Vector2(50.0, screen_center.y)
	paddle_right.position = Vector2(get_viewport_rect().size.x - 50.0, screen_center.y)


func _unhandled_input(event: InputEvent) -> void:
	if not game_started and event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()


func _on_start_button_pressed() -> void:
	if game_over_state:
		print("game over")
		game_over_state = false
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
	hud.hide_start_message()
	game_started = true
	ball.launch()


func game_over() -> void:
	game_started = false
	game_over_state = true
	ball.linear_velocity = Vector2.ZERO
	hud.show_start_message("Game Over - Click to Restart")
