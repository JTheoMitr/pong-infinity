extends Node2D

@onready var start_button = $CenterContainer/VBoxContainer/Button
@onready var title = $CenterContainer/VBoxContainer/RichTextLabel

func _ready() -> void:
	start_button.grab_focus()
	start_title_glow()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_two.tscn")

	#get_tree().change_scene_to_file("res://game_mode_menu.tscn")

func start_title_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title, "self_modulate:g", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:g", 0.95, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.95, 2.0)
	
	
