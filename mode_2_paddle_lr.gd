# res://Scripts/mode_2_paddle_LR.gd
extends StaticBody2D

@export var is_left: bool = true
@export var speed: float = 1000.0
@export var base_rotation := 0.0
@export var rotate_speed := 2.5
@export var rotate_return_speed := 6.0
@export var edge_offset := 40.0

var rotation_offset := 0.0


signal ball_hit_paddle(paddle: Node)


func _process(delta: float) -> void:
	# --- Vertical movement (shared control) ---
	var move_input := Input.get_axis("ui_up", "ui_down")

	var new_y := position.y + move_input * speed * delta
	var screen := get_viewport_rect().size

	# Clamp to vertical walls (cannot reach floor / ceiling)
	new_y = clamp(new_y, edge_offset, screen.y - edge_offset)
	position.y = new_y

	# Lock X to wall
	position.x = edge_offset if is_left else screen.x - edge_offset

	# --- Rotation (shared with all paddles) ---
	var rotate_input := 0.0
	if Input.is_action_pressed("ui_paddle_rotate_clockwise"):
		rotate_input += 1.0
	if Input.is_action_pressed("ui_paddle_rotate_counterclockwise"):
		rotate_input -= 1.0

	if rotate_input != 0.0:
		rotation_offset += rotate_input * rotate_speed * delta
	else:
		rotation_offset = lerp(rotation_offset, 0.0, rotate_return_speed * delta)

	rotation_offset = clamp(rotation_offset, -PI / 2, PI / 2)

	# Base rotation: vertical paddle
	rotation = base_rotation + rotation_offset


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_paddle", self)


func reset_paddle() -> void:
	var screen := get_viewport_rect().size
	position.y = screen.y * 0.5
	position.x = edge_offset if is_left else screen.x - edge_offset
	rotation_offset = 0.0
	rotation = base_rotation
