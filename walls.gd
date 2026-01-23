extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if get_tree().current_scene.has_method("game_over"):
		get_tree().current_scene.game_over()
