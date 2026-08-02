# res://Scripts/mode_2_paddle_TB.gd
extends StaticBody2D

@export var is_top: bool = true
@export var speed: float = 1000.0
@export var base_rotation: float = PI / 2.0
@export var rotate_speed: float = 2.5
@export var rotate_return_speed: float = 6.0
@export var edge_offset: float = 25.0

@export var mouse_control_enabled: bool = true
@export var mouse_move_threshold: float = 1.0

var rotation_offset: float = 0.0
var mouse_control_active: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

signal ball_hit_paddle(paddle: Node)


func _ready() -> void:
	last_mouse_position = get_viewport().get_mouse_position()


func _process(delta: float) -> void:
	var screen: Vector2 = get_viewport_rect().size
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	# Arrow keys/controller immediately take priority.
	var move_input: float = Input.get_axis(
		"ui_left",
		"ui_right"
	)

	if not is_zero_approx(move_input):
		mouse_control_active = false

		var keyboard_target_x: float = (
			position.x + move_input * speed * delta
		)

		position.x = clamp(
			keyboard_target_x,
			170.0,
			screen.x - 170.0
		)

	# Moving the mouse activates mouse tracking again.
	elif mouse_control_enabled:
		var mouse_distance: float = mouse_position.distance_to(
			last_mouse_position
		)

		if mouse_distance >= mouse_move_threshold:
			mouse_control_active = true

		if mouse_control_active:
			var target_x: float = clamp(
				mouse_position.x,
				170.0,
				screen.x - 170.0
			)

			position.x = move_toward(
				position.x,
				target_x,
				speed * delta
			)

	last_mouse_position = mouse_position

	# Lock Y to the appropriate edge.
	position.y = (
		edge_offset
		if is_top
		else screen.y - edge_offset
	)

	_update_rotation(delta)


func _update_rotation(delta: float) -> void:
	var rotate_input: float = 0.0

	if Input.is_action_pressed(
		"ui_paddle_rotate_clockwise"
	):
		rotate_input += 1.0

	if Input.is_action_pressed(
		"ui_paddle_rotate_counterclockwise"
	):
		rotate_input -= 1.0

	if not is_zero_approx(rotate_input):
		rotation_offset += (
			rotate_input
			* rotate_speed
			* delta
		)
	else:
		rotation_offset = lerp(
			rotation_offset,
			0.0,
			rotate_return_speed * delta
		)

	rotation_offset = clamp(
		rotation_offset,
		-PI / 2.0,
		PI / 2.0
	)

	rotation = base_rotation + rotation_offset


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		ball_hit_paddle.emit(self)


func reset_paddle() -> void:
	var screen: Vector2 = get_viewport_rect().size

	position.x = screen.x * 0.5
	position.y = (
		edge_offset
		if is_top
		else screen.y - edge_offset
	)

	rotation_offset = 0.0
	rotation = base_rotation

	mouse_control_active = false
	last_mouse_position = get_viewport().get_mouse_position()
