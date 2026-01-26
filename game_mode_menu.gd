extends Node2D


@onready var mode_1_button = $CenterContainer/VBoxContainer/Button
@onready var mode_2_button = $CenterContainer/VBoxContainer/Button2

func _ready() -> void:
	mode_1_button.grab_focus()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://main_two.tscn")
