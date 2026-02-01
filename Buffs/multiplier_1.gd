extends Area2D

signal ball_hit_multiplier_1(multiplier: Node)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_multiplier_1", self)
		self.queue_free() # this should be prefaced by an anim that gives a shatter or breaking effect
		print("multiplier_1")
