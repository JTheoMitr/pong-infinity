extends Area2D


@onready var lightning_anim: AnimatedSprite2D = $AnimatedSprite2D3
@onready var spinning_blue_crystal: AnimatedSprite2D = $AnimatedSprite2D

signal ball_hit_crystal_1(multiplier: Node)


func _ready() -> void:
	lightning_anim.play()
	spinning_blue_crystal.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_crystal_1", self)
		self.queue_free() 
		#print("crystal_1")


func _on_animated_sprite_2d_3_animation_finished() -> void:
	lightning_anim.stop()
	lightning_anim.hide()
	spinning_blue_crystal.show()
	
func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(spinning_blue_crystal, "self_modulate:a", 0.0, 1.5)
	
func _on_timer_timeout() -> void:
	start_fade_out()
	
func _on_timer_2_timeout() -> void:
	self.queue_free()
