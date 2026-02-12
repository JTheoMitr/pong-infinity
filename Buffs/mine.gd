extends Area2D

const mine_connect_sfx = preload("res://Assets/SFX/sfx_mine_1_connect.tscn")

@onready var mine_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var xplosion_anim: AnimatedSprite2D = $ExplosionAnim

signal mine_exploded

func _ready() -> void:
	xplosion_anim.frame = 0
	xplosion_anim.stop()
	xplosion_anim.hide()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("mine_exploded")
		print_debug("MINE_TRIGGERED")
		mine_anim.hide()
		xplosion_anim.show()
		xplosion_anim.play()
		var explosion_sfx = mine_connect_sfx.instantiate()
		get_parent().add_child(explosion_sfx)


func _on_explosion_anim_animation_finished() -> void:
	self.queue_free()
