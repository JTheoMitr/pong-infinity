# res://Scripts/paddle.gd
extends Area2D

@export var is_left: bool = true
@export var speed: float = 400.0
var perimeter_pos: float = 0.0

# Touch handling
var touch_y: float = -1.0
var touch_active: bool = false

func _ready() -> void:
	var screen := get_viewport_rect().size
	if is_left:
		perimeter_pos = 0.875    # halfway up the left edge
	else:
		perimeter_pos = 0.375    # halfway down the right edge
	position = perimeter_to_screen(perimeter_pos)



func _unhandled_input(event: InputEvent) -> void:
	# Handle touch and mouse drag the same way
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			# Start touch only if it’s on this paddle’s half
			if is_left and event.position.x < get_viewport_rect().size.x * 0.5:
				touch_active = true
				touch_y = event.position.y
			elif not is_left and event.position.x >= get_viewport_rect().size.x * 0.5:
				touch_active = true
				touch_y = event.position.y
		else:
			touch_active = false

	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if touch_active:
			touch_y = event.position.y


func _process(delta: float) -> void:
	var input_value := 0.0

	# --- Keyboard for desktop testing ---
	if is_left:
		input_value = Input.get_axis("s", "w")
	else:
		input_value = Input.get_axis("ui_up", "ui_down")

	# --- Touch / Mouse drag for mobile or desktop ---
	if touch_active:
		if touch_y < position.y:
			input_value = 1.0
		elif touch_y > position.y:
			input_value = -1.0

	perimeter_pos = fmod(perimeter_pos + 1.0 + input_value * (speed / 1000.0) * delta, 1.0)
	position = perimeter_to_screen(perimeter_pos)
	rotation = get_rotation_for_t(perimeter_pos)

func get_rotation_for_t(t: float) -> float:
	if t < 0.25:
		return deg_to_rad(90)
	elif t < 0.5:
		return deg_to_rad(180)
	elif t < 0.75:
		return deg_to_rad(270)
	else:
		return deg_to_rad(0)



func perimeter_to_screen(t: float) -> Vector2:
	var screen := get_viewport_rect().size
	if t < 0.25:
		return Vector2(screen.x * t * 4.0, 0.0)
	elif t < 0.5:
		return Vector2(screen.x, (t - 0.25) * 4.0 * screen.y)
	elif t < 0.75:
		return Vector2(screen.x - (t - 0.5) * 4.0 * screen.x, screen.y)
	else:
		return Vector2(0.0, screen.y - (t - 0.75) * 4.0 * screen.y)
