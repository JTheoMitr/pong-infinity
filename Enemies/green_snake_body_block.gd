extends StaticBody2D

var moving_up: bool = false
var moving_down: bool = false
var moving_right: bool = false
var moving_left: bool = false


func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	
	if moving_left:
		self.global_position.x -= 4
	if moving_right:
		self.global_position.x += 4
	if moving_down:
		self.global_position.y += 2
	if moving_up:
		self.global_position.y -= 2
	#need to check self.global_position for x and y and set new direction, screen size totalis (1152.0, 648.0). for testing no default is fine but will need to set for implementation
	if self.global_position.x > 1050:
		moving_left = true
		moving_right = false
	if self.global_position.x < 50:
		moving_left = false
		moving_right = true
		
	if self.global_position.y > 600:
		moving_up = true
		moving_down = false
	if self.global_position.y < 50:
		moving_up = false
		moving_down = true


func _on_timer_timeout() -> void:
	moving_down = false
	moving_up = false


func _on_timer_2_timeout() -> void:
	
	if moving_down:
		moving_down = false
		moving_up = true
	else:
		moving_up = false
		moving_down = true
