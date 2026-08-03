class_name LaserStrike
extends Node2D

signal impact(target_position: Vector2)
signal strike_finished

@export var beam_animation_name: StringName = &"default"
@export var explosion_animation_name: StringName = &"default"

@export var beam_travel_time: float = 0.35
@export var cleanup_delay: float = 0.15

@onready var beam_top_left: AnimatedSprite2D = $BeamTopLeft
@onready var beam_top_right: AnimatedSprite2D = $BeamTopRight
@onready var beam_bottom_left: AnimatedSprite2D = $BeamBottomLeft
@onready var beam_bottom_right: AnimatedSprite2D = $BeamBottomRight

@onready var impact_explosion: AnimatedSprite2D = $ImpactExplosion

@onready var fire_sound: AudioStreamPlayer = $FireSound
@onready var impact_sound: AudioStreamPlayer = $ImpactSound

var target_position: Vector2 = Vector2.ZERO
var screen_size: Vector2 = Vector2.ZERO



func begin_strike(
	new_target_position: Vector2,
	new_screen_size: Vector2
) -> void:
	target_position = new_target_position
	screen_size = new_screen_size

	_prepare_beams()
	_play_beams()

	if fire_sound.stream != null:
		fire_sound.play()

	await _move_beams_to_target()

	_trigger_impact()


func _prepare_beams() -> void:
	var top_left := Vector2.ZERO
	var top_right := Vector2(screen_size.x, 0.0)
	var bottom_left := Vector2(0.0, screen_size.y)
	var bottom_right := screen_size

	_place_beam(beam_top_left, top_left)
	_place_beam(beam_top_right, top_right)
	_place_beam(beam_bottom_left, bottom_left)
	_place_beam(beam_bottom_right, bottom_right)

	impact_explosion.position = target_position
	impact_explosion.visible = false


func _place_beam(
	beam: AnimatedSprite2D,
	start_position: Vector2
) -> void:
	beam.position = start_position
	beam.visible = true
	beam.frame = 0

	var direction: Vector2 = target_position - start_position
	beam.rotation = direction.angle()

	# Adjust this if your beam artwork points vertically by default.
	# For artwork pointing upward, use:
	# beam.rotation = direction.angle() + PI / 2.0


func _play_beams() -> void:
	_play_sprite(beam_top_left, beam_animation_name)
	_play_sprite(beam_top_right, beam_animation_name)
	_play_sprite(beam_bottom_left, beam_animation_name)
	_play_sprite(beam_bottom_right, beam_animation_name)


func _trigger_impact() -> void:
	_hide_beams()

	impact.emit(target_position)

	if impact_sound.stream != null:
		impact_sound.play()

	impact_explosion.visible = true
	_play_sprite(
		impact_explosion,
		explosion_animation_name
	)

	await _wait_for_animation_or_timeout(
		impact_explosion,
		1.0
	)

	await get_tree().create_timer(cleanup_delay).timeout

	strike_finished.emit()
	queue_free()


func _hide_beams() -> void:
	beam_top_left.stop()
	beam_top_right.stop()
	beam_bottom_left.stop()
	beam_bottom_right.stop()

	beam_top_left.hide()
	beam_top_right.hide()
	beam_bottom_left.hide()
	beam_bottom_right.hide()


func _play_sprite(
	sprite: AnimatedSprite2D,
	animation_name: StringName
) -> void:
	if sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
		return

	var animations: PackedStringArray = (
		sprite.sprite_frames.get_animation_names()
	)

	if not animations.is_empty():
		sprite.play(animations[0])


func _wait_for_animation_or_timeout(
	sprite: AnimatedSprite2D,
	maximum_time: float
) -> void:
	if sprite.sprite_frames == null:
		await get_tree().create_timer(maximum_time).timeout
		return

	var finished := false

	sprite.animation_finished.connect(
		func() -> void:
			finished = true,
		CONNECT_ONE_SHOT
	)

	var elapsed := 0.0

	while not finished and elapsed < maximum_time:
		var delta := get_process_delta_time()
		elapsed += delta
		await get_tree().process_frame

func _move_beams_to_target() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		beam_top_left,
		"position",
		target_position,
		beam_travel_time
	)

	tween.parallel().tween_property(
		beam_top_right,
		"position",
		target_position,
		beam_travel_time
	)

	tween.parallel().tween_property(
		beam_bottom_left,
		"position",
		target_position,
		beam_travel_time
	)

	tween.parallel().tween_property(
		beam_bottom_right,
		"position",
		target_position,
		beam_travel_time
	)

	await tween.finished
