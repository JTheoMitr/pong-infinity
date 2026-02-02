extends Area2D


@onready var lightning_anim: AnimatedSprite2D = $AnimatedSprite2D3
@onready var spinning_pyramid_pink: AnimatedSprite2D = $AnimatedSprite2D
signal ball_hit_multiplier_1(multiplier: Node)


func _ready() -> void:
	lightning_anim.play()
	spinning_pyramid_pink.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_multiplier_1", self)
		self.queue_free() # this should be prefaced by an anim that gives a shatter or breaking effect
		print("multiplier_1")


func _on_animated_sprite_2d_3_animation_finished() -> void:
	lightning_anim.stop()
	lightning_anim.hide()
	spinning_pyramid_pink.show()
	
