# res://Scripts/main.gd
extends Node2D

@onready var ball: RigidBody2D        = $Ball
@onready var paddle_left: StaticBody2D      = $PaddleLeft
@onready var paddle_right: StaticBody2D     = $PaddleRight
@onready var hud: CanvasLayer         = $HUD
@onready var cam: Camera2D            = $Camera2D

var game_started: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_start_message("Tap to Start")

	# Center everything relative to current viewport
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	cam.enabled = true
	cam.position = screen_center
	ball.position = screen_center
	paddle_left.position = Vector2(50.0, screen_center.y)              # near left wall
	paddle_right.position = Vector2(screen_size.x - 50.0, screen_center.y)  # near right wall

	print("Viewport size:", get_viewport_rect().size)
	print("Ball pos:", ball.position)
	print("Camera pos:", cam.position)
	print("Paddle Left: ", paddle_left.position)
	print("Paddle Right: ", paddle_right.position)
	print("Left paddle final global_position:", paddle_left.global_position)
	print("Right paddle final global_position:", paddle_right.global_position)



func _unhandled_input(event: InputEvent) -> void:
	# Start on first touch OR mouse click
	if not game_started and (
		(event is InputEventScreenTouch and event.pressed) or
		(event is InputEventMouseButton and event.pressed)
	):
		start_game()


func start_game() -> void:
	hud.hide_start_message()
	ball.launch()
	game_started = true


func game_over() -> void:
	game_started = false
	hud.show_start_message("Game Over - Tap or Click to Restart")
	ball.reset()
