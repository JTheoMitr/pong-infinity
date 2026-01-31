extends Area2D



func _on_area_entered(_area: Area2D) -> void:
	print("multiplier_1")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		print("multiplier_1")
