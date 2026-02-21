extends Node2D

@onready var start_button = $CenterContainer/VBoxContainer/Button
@onready var title = $RichTextLabel
@onready var panel = $Panel
@onready var slide_panel = $Panel3
@onready var start_timer = $Timer
@onready var button_1 = $CenterContainer/VBoxContainer/Button
@onready var button_2 = $CenterContainer/VBoxContainer/Button2
@onready var menu_music = $AudioStreamPlayer
@onready var return_button = $ControlsPopup/ReturnButton
@onready var controls_pop = $ControlsPopup
@onready var cyborg_head = $AnimatedSprite2D
@onready var difficulty_select = $CenterContainer/DifficultySelect
@onready var v_box_1 = $CenterContainer/VBoxContainer
@onready var easy_button = $CenterContainer/DifficultySelect/HBoxContainer/Button
@onready var normal_button = $CenterContainer/DifficultySelect/HBoxContainer/Button2
@onready var hard_button = $CenterContainer/DifficultySelect/HBoxContainer/Button3
@onready var bgnd = $CityBgnd
@onready var wires = $Sprite2D2

const ButtonClick = preload("res://Assets/SFX/sfx_button_click_1.tscn")

var panel_sliding: bool = false
var cyborg_head_zoom: bool = false
var cyborg_head_fade: bool = false

func _process(_delta: float) -> void:
	if panel_sliding:
		slide_panel.global_position.y += 3
		title.self_modulate.a -= .005
		if cyborg_head.frame > 8:
			cyborg_head.stop()
			print_debug("frame 8")
	if cyborg_head_zoom:
		cyborg_head.scale.x += 0.2
		cyborg_head.scale.y += 0.2
		panel.scale.x += 0.07
		panel.scale.y += 0.1
		panel.global_position.x -= 6
		panel.global_position.y -= 2
		bgnd.self_modulate.r -= .005
		bgnd.self_modulate.g -= .005
		bgnd.self_modulate.b -= .005
		cyborg_head.global_position.y -= 2.8
	if cyborg_head_fade:
		cyborg_head.self_modulate.a -= .01
	
		

func _ready() -> void:
	start_button.grab_focus()
	start_title_glow()
	cyborg_head.play("normal")
	v_box_1.show()
	difficulty_select.hide()
	cyborg_head.scale.x = 3.0
	cyborg_head.scale.y = 3.0
	
	

func _on_button_pressed() -> void:
	v_box_1.hide()
	difficulty_select.show()
	normal_button.grab_focus()

func start_title_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title, "self_modulate:g", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:g", 0.95, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.95, 2.0)
	
	


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://main_two.tscn")


func _on_audio_stream_player_finished() -> void:
	menu_music.play()


func _on_button_2_pressed() -> void:
	controls_pop.popup()
	return_button.grab_focus()


func _on_return_button_pressed() -> void:
	controls_pop.hide()
	
func _initiate_visor() -> void:
	var clicked = ButtonClick.instantiate()
	get_parent().add_child(clicked)
	panel_sliding = true
	button_1.hide()
	button_2.hide()
	start_timer.start()
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_db", -50.0, 5.0)
	


func _on_button_focus_entered() -> void:
	cyborg_head.play("easy")
	#these buttons will emit the signal that sets base diffulty serttings (ball base speed, enemy spawn times, etc)


func _on_button_2_focus_entered() -> void:
	cyborg_head.play("normal")


func _on_button_3_focus_entered() -> void:
	cyborg_head.play("hard")


func _on_easybutton_pressed() -> void:
	#_initiate_visor()
	cyborg_head_zoom = true
	await get_tree().create_timer(2.0).timeout
	wires.hide()
	panel_sliding = true
	bgnd.hide()
	panel.hide()
	difficulty_select.hide()
	title.hide()
	
	await get_tree().create_timer(1.5).timeout
	cyborg_head_fade = true
	


func _on_normalbutton_pressed() -> void:
	_initiate_visor()


func _on_hardbutton_pressed() -> void:
	_initiate_visor()
