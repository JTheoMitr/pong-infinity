extends StaticBody2D

func _process(_delta: float) -> void:
	self.rotation_degrees += 3
	
func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "self_modulate:a", 0.0, 1.5)
	
func _on_timer_timeout() -> void:
	start_fade_out()
	
func _on_timer_2_timeout() -> void:
	self.queue_free()
