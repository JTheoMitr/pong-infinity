# res://Scripts/ball.gd
extends RigidBody2D

@export var speed: float = 400.0
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree
func _ready() -> void:
	reset()


func launch() -> void:
	# Start moving slightly off-center to avoid straight bounce
	var dir := Vector2.LEFT.rotated(deg_to_rad(randf_range(-15.0, 15.0)))
	linear_velocity = dir * speed


func reset() -> void:
	# Recenter the ball in the middle of the viewport
	position = get_viewport_rect().size * 0.5
	linear_velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	# Check if the ball is out of bounds (missed by paddles)
	var screen_size := get_viewport_rect().size
	if position.x < 0.0 or position.x > screen_size.x \
	or position.y < 0.0 or position.y > screen_size.y:
		if get_tree().current_scene.has_method("game_over"):
			get_tree().current_scene.game_over()
		reset()
