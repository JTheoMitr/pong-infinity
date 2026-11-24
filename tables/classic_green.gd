extends Node2D

@onready var bgnd_layer_2: Sprite2D = $Sprite2D2


func _ready() -> void:
	print("Classic Green loaded")
	start_background_glow()


func start_background_glow() -> void:
	print("Background glow started")

	var tween := create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_loops()
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.95, 2.0)
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.10, 2.0)
