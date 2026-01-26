extends Node2D

@onready var start_button = $CenterContainer/VBoxContainer/Button

func _ready() -> void:
	start_button.grab_focus()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_mode_menu.tscn")
