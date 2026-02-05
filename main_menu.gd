extends Node2D

@onready var start_button = $CenterContainer/VBoxContainer/Button
@onready var title = $CenterContainer/VBoxContainer/RichTextLabel
@onready var panel = $Panel
@onready var start_timer = $Timer

const ButtonClick = preload("res://Assets/SFX/sfx_button_click_1.tscn")

var panel_sliding: bool = false

func _process(_delta: float) -> void:
	if panel_sliding:
		panel.global_position.y += 3

func _ready() -> void:
	start_button.grab_focus()
	start_title_glow()

func _on_button_pressed() -> void:
	var clicked = ButtonClick.instantiate()
	get_parent().add_child(clicked)
	panel_sliding = true
	start_timer.start()


func start_title_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title, "self_modulate:g", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:g", 0.95, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.95, 2.0)
	
	


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://main_two.tscn")
