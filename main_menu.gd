extends Node2D

@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var title = $CanvasLayer/RichTextLabel
@onready var panel = $CanvasLayer/Panel
@onready var slide_panel = $CanvasLayer/Panel3
@onready var start_timer = $Timer
@onready var color_rect = $CanvasLayer/ColorRect
@onready var shader_mat = color_rect.material
@onready var button_1 = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var button_2 = $CanvasLayer/CenterContainer/VBoxContainer/Button2
@onready var menu_music = $AudioStreamPlayer
@onready var return_button = $ControlsPopup/ReturnButton
@onready var controls_pop = $ControlsPopup
@onready var cyborg_head = $CanvasLayer/AnimatedSprite2D
@onready var difficulty_select = $CanvasLayer/CenterContainer/DifficultySelect
@onready var v_box_1 = $CanvasLayer/CenterContainer/VBoxContainer
@onready var easy_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/Button
@onready var normal_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/Button2
@onready var hard_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/Button3
@onready var bgnd = $CityBgnd
@onready var wires = $CanvasLayer/Sprite2D2
@onready var speak = $NeuroballSpoken

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
		wires.self_modulate.a -= .05
		#bgnd.scale.x += .3
		#bgnd.scale.y += .8
		cyborg_head.global_position.y -= 2.8
		#bgnd.global_position.y += 10
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
	await get_tree().create_timer(1.0).timeout
	speak.play()
	
	

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
	print_debug("timed")
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
	#_initiate_visor()
	cyborg_head_zoom = true
	fade_out_static()
	await get_tree().create_timer(1.0).timeout
	panel_sliding = true
	start_timer.start()
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_db", -50.0, 5.0)
	bgnd.hide()
	panel.hide()
	difficulty_select.hide()
	title.hide()
	
	await get_tree().create_timer(2.5).timeout
	cyborg_head_fade = true
	


func _on_button_focus_entered() -> void:
	cyborg_head.play("easy")
	#these buttons will emit the signal that sets base diffulty serttings (ball base speed, enemy spawn times, etc)


func _on_button_2_focus_entered() -> void:
	cyborg_head.play("normal")


func _on_button_3_focus_entered() -> void:
	cyborg_head.play("hard")


func _on_easybutton_pressed() -> void:
	pass
	


func _on_normalbutton_pressed() -> void:
	_initiate_visor()


func _on_hardbutton_pressed() -> void:
	pass


	
func fade_out_static():
	var mat := color_rect.material as ShaderMaterial
	if mat == null:
		print("No shader material!")
		return

	var tween := create_tween()
	tween.tween_method(
		func(value):
			mat.set_shader_parameter("opacity", value),
		1.0,
		0.0,
		1.0
	)
