# res://Scripts/ball.gd
extends RigidBody2D

@export var base_speed: float = 400.0
var direction: Vector2 = Vector2.ZERO
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	reset()


func launch() -> void:
	# Launch either left or right randomly at a slight vertical angle
	var side: int = -1 if randi() % 2 == 0 else 1
	var angle_offset: float = deg_to_rad(randf_range(-15.0, 15.0))
	direction = Vector2(side, 0).rotated(angle_offset).normalized()
	linear_velocity = direction * base_speed


func reset() -> void:
	position = get_viewport_rect().size * 0.5
	linear_velocity = Vector2.ZERO
	direction = Vector2.ZERO


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("walls"):
		if get_tree().current_scene.has_method("game_over"):
			get_tree().current_scene.game_over()
		reset()


func bounce_from_paddle(paddle: Node) -> void:
	# Reflect direction depending on where on the paddle you hit
	var normal: Vector2 = (position - paddle.position).normalized()
	direction = direction.bounce(normal).normalized()
	print("bounce")
	# --- keep constant speed ---
	linear_velocity = direction * base_speed


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Maintain exact constant speed each physics tick
	if linear_velocity.length() > 0.0:
		direction = linear_velocity.normalized()
		linear_velocity = direction * base_speed
