# res://Scripts/hud.gd
extends CanvasLayer

@onready var label: Label = $CenterContainer/VBoxContainer/Label
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var countdown_label: Label = $CountdownLabel
@onready var pause_label: Label = $PauseLabel
@onready var center_container = $CenterContainer
@onready var score_label: Label = $ScoreLabel

signal start_button_pressed


func _ready() -> void:
	label.text = "PONG ∞"
	label.visible = true
	countdown_label.visible = false
	start_button.visible = true
	pause_label.visible = false
	score_label.visible = false
	start_button.pressed.connect(_on_start_button_pressed)
	


func _on_start_button_pressed() -> void:
	start_button.visible = false
	label.visible = false
	countdown_label.visible = true
	emit_signal("start_button_pressed")

func show_pause_overlay(paused: bool) -> void:
	pause_label.visible = paused
	score_label.visible = paused

func show_start_message(text: String) -> void:
	label.text = text
	label.visible = true
	start_button.visible = true
	countdown_label.visible = false


func hide_start_message() -> void:
	label.visible = false
	start_button.visible = false
	countdown_label.visible = false


func show_countdown(number: int) -> void:
	countdown_label.text = str(number)
	countdown_label.visible = true


func hide_countdown() -> void:
	countdown_label.visible = false
	
func update_score(value: int) -> void:
	score_label.text = "Score: " + str(value)
