extends Area2D


func _on_body_entered(body: Node2D) -> void:
	
	var main := get_tree().current_scene
	if main.has_method("is_game_active") and main.is_game_active():
		main.game_over()
