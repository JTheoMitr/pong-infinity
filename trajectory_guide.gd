
# res://Scripts/trajectory_guide.gd
extends Node2D

@export var guide_enabled: bool = true

@export_group("Prediction")
@export var activation_distance: float = 260.0
@export var full_visibility_distance: float = 90.0
@export var ricochet_length: float = 180.0

@export_group("Appearance")
@export var guide_color: Color = Color(1.0, 0.15, 0.2)
@export var line_width: float = 3.5
@export var glow_width: float = 14.0
@export var maximum_opacity: float = 0.7
@export var fade_speed: float = 9.0

@onready var ball: CharacterBody2D = $"../Ball"

@onready var paddles: Array[StaticBody2D] = [
	$"../PaddleLeft",
	$"../PaddleRight",
	$"../PaddleTop",
	$"../PaddleBottom"
]

var incoming_line: Line2D
var outgoing_line: Line2D
var incoming_glow: Line2D
var outgoing_glow: Line2D

var current_opacity: float = 0.0


func _ready() -> void:
	process_physics_priority = 100

	incoming_glow = _create_line(glow_width, 0.15)
	outgoing_glow = _create_line(glow_width, 0.15)

	incoming_line = _create_line(line_width, 1.0)
	outgoing_line = _create_line(line_width, 1.0)

	z_index = 50


func _create_line(
	width: float,
	alpha_multiplier: float
) -> Line2D:
	var line := Line2D.new()
	line.width = width

	line.default_color = Color(
		guide_color.r,
		guide_color.g,
		guide_color.b,
		alpha_multiplier
	)

	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true

	add_child(line)
	return line


func _physics_process(delta: float) -> void:
	if not guide_enabled:
		_fade_out(delta)
		return

	if ball.direction.is_zero_approx():
		_fade_out(delta)
		return

	var direction: Vector2 = ball.direction.normalized()
	var start: Vector2 = ball.global_position

	var closest_hit: Dictionary = {}
	var closest_distance: float = INF

	var space_state := get_world_2d().direct_space_state

	# Test each paddle independently.
	# All other objects are ignored.
	for paddle: StaticBody2D in paddles:
		var query := PhysicsRayQueryParameters2D.create(
			start,
			start + direction * activation_distance,
			1
		)

		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.exclude = [ball.get_rid()]

		var result: Dictionary = (
			space_state.intersect_ray(query)
		)

		if result.is_empty():
			continue

		if result["collider"] != paddle:
			continue

		var distance: float = (
			start.distance_to(result["position"])
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_hit = result

	if closest_hit.is_empty():
		_fade_out(delta)
		return

	var hit_position: Vector2 = closest_hit["position"]
	var normal: Vector2 = closest_hit["normal"]

	var visibility: float = 1.0 - inverse_lerp(
		full_visibility_distance,
		activation_distance,
		closest_distance
	)

	visibility = clampf(visibility, 0.0, 1.0)

	current_opacity = move_toward(
		current_opacity,
		visibility * maximum_opacity,
		fade_speed * delta
	)

	var reflected: Vector2 = (
		direction.bounce(normal).normalized()
	)

	var ricochet_end: Vector2 = (
		hit_position + reflected * ricochet_length
	)

	_set_line_points(incoming_line, start, hit_position)
	_set_line_points(incoming_glow, start, hit_position)

	_set_line_points(outgoing_line, hit_position, ricochet_end)
	_set_line_points(outgoing_glow, hit_position, ricochet_end)

	_update_opacity()


func _set_line_points(
	line: Line2D,
	start: Vector2,
	end: Vector2
) -> void:
	line.points = PackedVector2Array([
		to_local(start),
		to_local(end)
	])


func _fade_out(delta: float) -> void:
	current_opacity = move_toward(
		current_opacity,
		0.0,
		fade_speed * delta
	)

	_update_opacity()


func _update_opacity() -> void:
	modulate.a = current_opacity


func set_guide_enabled(value: bool) -> void:
	guide_enabled = value

	if not guide_enabled:
		current_opacity = 0.0
		_update_opacity()
