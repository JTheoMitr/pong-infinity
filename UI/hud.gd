# res://Scripts/hud.gd
extends CanvasLayer

@onready var label: Label = $Label

func _ready() -> void:
	label.visible = true
	label.text = "PONG ∞"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH


func show_start_message(text: String) -> void:
	label.text = text
	label.visible = true


func hide_start_message() -> void:
	label.visible = false
