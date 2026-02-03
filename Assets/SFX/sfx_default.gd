extends AudioStreamPlayer


func _on_finished() -> void:
	self.queue_free()
