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
	ball.position = screen_center
	paddle_left.position = Vector2(50.0, screen_center.y)
	paddle_right.position = Vector2(get_viewport_rect().size.x - 50.0, screen_center.y)
	ball.linear_velocity = Vector2.ZERO
	ball.direction = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if not game_started and event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()


func _on_start_button_pressed() -> void:
	if game_over_state:
		game_over_state = false
		reset_positions(get_viewport_rect().size * 0.5)
	await countdown_and_start()


func countdown_and_start() -> void:
	for i in range(3, 0, -1):
		hud.show_countdown(i)
		await get_tree().create_timer(1.0).timeout
	hud.hide_countdown()
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
