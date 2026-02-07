extends Area2D

const thunder_sfx = preload("res://Assets/SFX/sfx_thunder_2.tscn")

@onready var lightning_anim: AnimatedSprite2D = $AnimatedSprite2D3
@onready var spinning_pyramid_pink: AnimatedSprite2D = $AnimatedSprite2D
@onready var spinning_pyramid_red: AnimatedSprite2D = $AnimatedSprite2D2
@onready var barriers: Area2D = $Barriers
signal ball_hit_multiplier_1(multiplier: Node)


func _ready() -> void:
	lightning_anim.frame = 0
	lightning_anim.play()
	var thunder_strike = thunder_sfx.instantiate()
	get_parent().add_child(thunder_strike)
	spinning_pyramid_pink.hide()
	
func _process(_delta: float) -> void:
	barriers.rotation_degrees += 3

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_multiplier_1", self)
		self.queue_free() # this should be prefaced by an anim that gives a shatter or breaking effect
		print("multiplier_1")


func _on_animated_sprite_2d_3_animation_finished() -> void:
	lightning_anim.stop()
	lightning_anim.hide()
	spinning_pyramid_pink.show()
	
func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(spinning_pyramid_pink, "self_modulate:a", 0.0, 1.5)
	
func _on_timer_timeout() -> void:
	start_fade_out()
	
func _on_timer_2_timeout() -> void:
	self.queue_free()


func _on_barriers_body_entered(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return

	# --- MANUAL BOUNCE ---
	var to_ball: Vector2 = (body.global_position - global_position).normalized()
	body.direction = body.direction.bounce(to_ball).normalized()
	body.velocity = body.direction * body.base_speed

	#emit_signal("ball_hit_barrier", self)
