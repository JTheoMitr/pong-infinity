extends Area2D

const mine_connect_sfx = preload("res://Assets/SFX/sfx_mine_1_connect.tscn")

@onready var mine_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var xplosion_anim: AnimatedSprite2D = $ExplosionAnim
@onready var mine_field: CollisionShape2D = $CollisionShape2D
@onready var light: Sprite2D = $Light
@onready var light_timer: Timer = $LightTimer

signal mine_exploded

func _ready() -> void:
	xplosion_anim.frame = 0
	xplosion_anim.stop()
	xplosion_anim.hide()
	mine_field.disabled = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("mine_exploded")
		print_debug("MINE_TRIGGERED")
		mine_anim.hide()
		light_timer.stop()
		light.hide()
		xplosion_anim.show()
		xplosion_anim.play()
		mine_field.set_deferred("disabled", true)
		var explosion_sfx = mine_connect_sfx.instantiate()
		get_parent().add_child(explosion_sfx)


func _on_explosion_anim_animation_finished() -> void:
	self.queue_free()


func _on_light_timer_timeout() -> void:
	if light.visible == false:
		light.visible = true
	else:
		light.visible = false
