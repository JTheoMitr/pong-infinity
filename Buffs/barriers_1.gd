extends StaticBody2D

@onready var anim1: AnimatedSprite2D = $AnimBarrier
@onready var anim2: AnimatedSprite2D = $AnimBarrier2

func _process(_delta: float) -> void:
	self.rotation_degrees += 3
	
func start_fade_out() -> void:
	var tween := create_tween()
	var tween2 := create_tween()
	tween.tween_property(anim1, "self_modulate:a", 0.0, 1.5)
	tween2.tween_property(anim2, "self_modulate:a", 0.0, 1.5)
	
func _on_timer_timeout() -> void:
	start_fade_out()
	
func _on_timer_2_timeout() -> void:
	self.queue_free()
