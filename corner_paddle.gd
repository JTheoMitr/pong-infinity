# res://Scripts/paddle.gd
extends StaticBody2D


signal ball_hit_paddle(paddle: Node)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		print("Cornerhit")
		emit_signal("ball_hit_paddle", self)
		
		
