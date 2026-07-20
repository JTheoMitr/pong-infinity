extends CharacterBody2D

@export var base_speed := 300.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_anim: AnimatedSprite2D = $FireAnimatedSprite2D
@onready var ice_anim: AnimatedSprite2D = $IceAnimatedSprite2D2
@onready var fire_timer: Timer = $Timer
@onready var ice_timer: Timer = $Timer2


var direction: Vector2 = Vector2.ZERO




func _ready() -> void:
	reset()
	fire_anim.hide()
	ice_anim.hide()
	apply_equipped_cosmetic()


func launch() -> void:
	await get_tree().physics_frame
	#await get_tree().physics_frame  # keep this – good call

	var side := -1 if randi() % 2 == 0 else 1
	var angle := deg_to_rad(randf_range(-15.0, 15.0))
	direction = Vector2(side, 0).rotated(angle).normalized()


func _physics_process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return

	velocity = direction * base_speed

	var collision := move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision)
		
	#fire animation angle
	fire_anim.rotation = lerp_angle(
	fire_anim.rotation,
	direction.angle(), #direction.angle() + PI,
	20.0 * delta
	)


func handle_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.get_collider()
	var normal: Vector2 = collision.get_normal()

	if collider.is_in_group("paddle"):
		# Separate FIRST
		global_position += normal * 2.0

		# Reflect direction
		direction = direction.bounce(normal).normalized()
		velocity = direction * base_speed

	elif collider.is_in_group("walls"):
		if get_tree().current_scene.has_method("game_over"):
			get_tree().current_scene.game_over()
		reset()


func reset() -> void:
	global_position = get_viewport_rect().size * 0.5
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	
func enable_on_fire() -> void:
	fire_anim.show()
	fire_timer.start()
	
func disable_on_fire() -> void:
	fire_anim.hide()
	#print_debug("fire_disabled")

func _on_timer_timeout() -> void:
	disable_on_fire()
	
func enable_ice_cube() -> void:
	ice_anim.show()
	ice_timer.start()
	
func disable_ice_cube() -> void:
	ice_anim.hide()
	#print_debug("ice_cube_disabled")

func _on_timer_2_timeout() -> void:
	disable_ice_cube()
func apply_equipped_cosmetic() -> void:
	var ball_id: String = SaveManager.equipped_ball_id
	var ball_data: Dictionary = BallCatalog.get_ball(ball_id)

	var equipped_frames := ball_data.get("sprite_frames") as SpriteFrames

	if equipped_frames == null:
		push_warning(
			"No SpriteFrames resource found for ball: %s"
			% ball_id
		)
		return

	animated_sprite.sprite_frames = equipped_frames

	var animation_names: PackedStringArray = (
		animated_sprite.sprite_frames.get_animation_names()
	)

	if animation_names.is_empty():
		push_warning(
			"Ball has no animations: %s"
			% ball_id
		)
		return

	if animated_sprite.sprite_frames.has_animation("spin"):
		animated_sprite.play("spin")
	elif animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	else:
		animated_sprite.play(animation_names[0])
