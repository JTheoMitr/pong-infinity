extends StaticBody2D

@onready var timer = $Timer
@onready var timer2 = $Timer2
@onready var anim = $AnimatedSprite2D

var moving_up: bool = false
var moving_down: bool = false
var moving_right: bool = true
var moving_left: bool = false

var hit_counter: int = 0

signal ball_hit_spinning_head
signal panel_pop
#signal restarting


func _ready() -> void:
	await get_tree().create_timer(0.25).timeout
	timer.start()
	timer2.start()
	#need to add an area2d and counter to track hits, first and second hit adjust modulation (and glitch intensity), and the third hit explodes it with particle effects and adds 50 pts...sfx on all hits and explode sfx too
	
func _process(_delta: float) -> void:
	
	rotation_degrees += 2
	
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
		#self.rotation_degrees += 180
		moving_left = true
		moving_right = false
	if self.global_position.x < 50:
		#self.rotation_degrees += 180
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


func start_fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(anim, "self_modulate:a", 0.0, 1.5)




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		emit_signal("ball_hit_spinning_head", self)
		hit_counter += 1
		if hit_counter > 1:
			self.queue_free()
			emit_signal("panel_pop")
		print_debug("spinning head")


func _on_timer_3_timeout() -> void:
	start_fade_out()


func _on_timer_4_timeout() -> void:
	self.queue_free()
	#emit_signal("restarting")
