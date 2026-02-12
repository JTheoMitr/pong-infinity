extends Area2D

signal ball_on_fire

func _process(_delta: float) -> void:
	self.rotation_degrees += 2
	
func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 2.5)
	#this fade out does not seem to be working, try it on each anim individually
	
func _on_timer_timeout() -> void:
	start_fade_out()
	
func _on_timer_2_timeout() -> void:
	self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_on_fire")
		print_debug("ONFIRE")
