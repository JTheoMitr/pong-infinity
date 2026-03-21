extends Area2D

const mine_connect_sfx = preload("res://Assets/SFX/sfx_mine_1_connect.tscn")

@onready var mine_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var xplosion_anim: AnimatedSprite2D = $ExplosionAnim
@onready var mine_field: CollisionShape2D = $CollisionShape2D
@onready var light: Sprite2D = $Light
@onready var light_timer: Timer = $LightTimer
@onready var drop_anim: AnimatedSprite2D = $AnimatedSprite2D2

signal mine_exploded

var dropping: bool = true

func _ready() -> void:
	xplosion_anim.frame = 0
	xplosion_anim.stop()
	xplosion_anim.hide()
	mine_anim.hide()
	light.hide()
	mine_field.disabled = true
	drop_anim.frame = 80
	drop_anim.position.y = -300
	mine_anim.frame = 209

	
func _process(_delta: float) -> void:
	if dropping:
		if drop_anim.position.y < -8:
			drop_anim.position.y += 3
		else:
			drop_anim.queue_free()
			#print_debug("drop_stop")
			dropping = false
			mine_anim.show()
			light_timer.start()
			mine_field.disabled = false
			


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("mine_exploded")
		#print_debug("MINE_TRIGGERED")
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
		
func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(mine_anim, "self_modulate:a", 0.0, 1.5)


func _on_fade_timer_timeout() -> void:
	start_fade_out()


func _on_end_timer_timeout() -> void:
	self.queue_free()
