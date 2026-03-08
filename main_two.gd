# res://Scripts/main_two.gd
extends Node2D

const game_over_sfx = preload("res://Assets/SFX/sfx_game_over.tscn")
const paddle_hit_sfx = preload("res://Assets/SFX/sfx_paddle_hit_1.tscn")
const panel_hit_sfx = preload("res://Assets/SFX/sfx_panel_hit_1.tscn")
const panel_destroyed_sfx = preload("res://Assets/SFX/sfx_panel_destroyed_1.tscn")
const multi_connect_sfx = preload("res://Assets/SFX/sfx_multi_1_connect.tscn")
const corner_hit_sfx = preload("res://Assets/SFX/sfx_corner_hit_1.tscn")
const crystal_hit_sfx = preload("res://Assets/SFX/sfx_crystal_hit_1.tscn")
const score_dbl_popup = preload("res://Buffs/score_doubled_popup.tscn")


@onready var ball: CharacterBody2D = $Ball
@onready var paddle_left: StaticBody2D = $PaddleLeft
@onready var paddle_right: StaticBody2D = $PaddleRight
@onready var paddle_top: StaticBody2D = $PaddleTop
@onready var paddle_bottom: StaticBody2D = $PaddleBottom
@onready var corner_tl: StaticBody2D = $Corners/CornerTL
@onready var corner_tr: StaticBody2D = $Corners/CornerTR
@onready var corner_br: StaticBody2D = $Corners/CornerBR
@onready var corner_bl: StaticBody2D = $Corners/CornerBL

@onready var multi1_timer: Timer = $Multi1Timer
@onready var crystal1_timer: Timer = $CrystalTimer
@onready var mine_timer: Timer = $MineTimer
@onready var ice_mine_timer: Timer = $IceMineTimer
@onready var ball_fire_timer: Timer = $BallFireTimer
@onready var ball_ice_timer: Timer = $BallIceTimer
@onready var panel_timer_1: Timer = $PanelTimer1

@onready var hud: CanvasLayer = $HUD
@onready var cam: Camera2D = $Camera2D
@onready var bgnd_layer_2: Sprite2D = $Sprite2D2
@onready var particles_root: Node2D = $Particles

@onready var level_music: AudioStreamPlayer = $LevelMusic


@export var impact_particles_scene: PackedScene
@export var impact_particles_multiplier_1: PackedScene
@export var impact_particles_panel_pop: PackedScene
@export var impact_particles_crystal_1: PackedScene
@export var impact_particles_white: PackedScene
@export var multiplier_1: PackedScene
@export var score_crystal_1: PackedScene
@export var barriers: PackedScene
@export var fire_zone: PackedScene
@export var mine_1: PackedScene
@export var ice_zone: PackedScene
@export var ice_mine_1: PackedScene
@export var silver_panel_1: PackedScene


var game_started: bool = false
var start_pressed: bool = false
var game_over_state: bool = false
var fade_up: bool = false
var fade_down: bool = true
var score := 0
var final_score_to_submit := 0
var glow_time := 0.0
var buff_ids: Array[int] = []
var barrier_id: int = 0
var ball_is_on_fire: bool = false
var ball_is_frozen: bool = false
var awaiting_score_submit: bool = false

# --- Camera Effects ---
var shake_strength := 0.0
var shake_decay := 5.0
var original_cam_position := Vector2.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	process_mode = Node.PROCESS_MODE_ALWAYS  # Allow input when paused
	hud.show_start_message("Get Ready")
	hud.start_button_pressed.connect(_on_start_button_pressed)
	hud.submit_score_button_pressed.connect(_on_score_button_pressed)
	start_background_glow()
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	print_debug(screen_size)
	cam.enabled = true
	cam.position = screen_center
	reset_positions(screen_center)
	ball.visible = false
	original_cam_position = cam.position
	
	# local test for leaderboard:
	
	#LeaderboardService.set_display_name_best_effort("John")
	#LeaderboardService.submit_score_best_effort(randi_range(0, 999))
#
	#LeaderboardService.fetch_top_best_effort(func(records: Array, ok: bool, err: String) -> void:
		#print("ok:", ok, "err:", err, "count:", records.size())
		#for rec in records:
			#print(rec.rank, rec.username, rec.score)
	#)

	
	await get_tree().create_timer(1.0).timeout
	spawn_impact_particles(get_viewport_rect().size * 2.5, Vector2.RIGHT)
	spawn_impact_particles_crystal1(get_viewport_rect().size * 2.5)
	spawn_impact_particles_multiplier1(get_viewport_rect().size * 2.5)
	paddle_left.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_right.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_top.ball_hit_paddle.connect(_on_paddle_hit)
	paddle_bottom.ball_hit_paddle.connect(_on_paddle_hit)
	corner_tl.ball_hit_paddle.connect(_on_corner_hit)
	corner_tr.ball_hit_paddle.connect(_on_corner_hit)
	corner_br.ball_hit_paddle.connect(_on_corner_hit)
	corner_bl.ball_hit_paddle.connect(_on_corner_hit)
	

	
func _process(delta: float) -> void:
	if shake_strength > 0.0:
		var offset := Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength

		cam.position = original_cam_position + offset

		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)

		if shake_strength < 0.5:
			shake_strength = 0.0
			cam.position = original_cam_position


func reset_positions(screen_center: Vector2) -> void:
	# Reset ball (CharacterBody2D)
	ball.global_position = screen_center
	ball.velocity = Vector2.ZERO
	ball.direction = Vector2.ZERO

	# Reset paddles
	paddle_left.reset_paddle()
	paddle_right.reset_paddle()
	paddle_top.reset_paddle()
	paddle_bottom.reset_paddle()



func _unhandled_input(event: InputEvent) -> void:
	# --- Start game with Space / Start button ---
	if not game_started and not awaiting_score_submit and event.is_action_pressed("ui_accept"):
		_on_start_button_pressed()

	# --- Pause / Unpause ---
	elif game_started and event.is_action_pressed("ui_pause"):
		toggle_pause()

	# --- Mobile tap pause: tap center third of screen ---
	elif game_started and event is InputEventScreenTouch and event.pressed:
		var screen_size := get_viewport_rect().size
		var third_x := screen_size.x / 3.0
		if event.position.x > third_x and event.position.x < third_x * 2:
			toggle_pause()
			print("pause by touch")
			
	elif event.is_action_pressed("ui_reset_paddles"):
		# Reset paddles
		paddle_left.reset_paddle()
		paddle_right.reset_paddle()
		paddle_top.reset_paddle()
		paddle_bottom.reset_paddle()
		


func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	hud.show_pause_overlay(get_tree().paused)
	print(ball.base_speed)


func _on_start_button_pressed() -> void:
	if game_over_state:
		print("game over")
		game_over_state = false
		clear_all_buffs()
	if start_pressed == false:
		hud.hide_start_message()
		hud.hide_score()
		ball.visible = true
		reset_score()
		#multi1_timer.start()
		#crystal1_timer.start()
		#mine_timer.start()
		var screen_size := get_viewport_rect().size
		var screen_center := screen_size * 0.5
		reset_positions(screen_center)
		start_pressed = true
		hud.hide_leaderboard()
		await countdown_and_start()


func countdown_and_start() -> void:
	for i in range(3, 0, -1):
		hud.show_countdown(i)
		await get_tree().create_timer(1.0).timeout
	hud.hide_countdown()

	# Wake the ball back up
	start_game()
	
func start_game() -> void:
	ball.base_speed = 390.0
	game_started = true
	start_pressed = false
	ball.launch()
	mine_timer.start()
	crystal1_timer.start()
	panel_timer_1.start()
	#hud.hide_leaderboard()
	#ice_mine_timer.start()



func game_over() -> void:
	game_started = false
	game_over_state = true
	awaiting_score_submit = true
	final_score_to_submit = score
	var game_over_chime = game_over_sfx.instantiate()
	get_parent().add_child(game_over_chime)
	stop_all_timers()
	#create method to clear all buffs as well
	ball.velocity = Vector2.ZERO
	ball.direction = Vector2.ZERO
	ball.disable_on_fire()
	ball_is_on_fire = false
	hud.show_score()
	
	await get_tree().create_timer(3.0).timeout
	LeaderboardService.fetch_top_best_effort(func(records: Array, ok: bool, err: String) -> void:
		hud.show_leaderboard(records, ok, err)
	);
	hud.show_score_submit()

func _on_paddle_hit(paddle: Node) -> void:
	var paddle_bonk = paddle_hit_sfx.instantiate()
	get_parent().add_child(paddle_bonk)
	#score += 15
	#hud.update_score(score)
	ball.base_speed *= 1.005 #was 1.03
	print("paddle hit")
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles(ball.global_position, hit_dir)
	
	if ball_is_on_fire:
		score += 30
	else:
		score += 15
	
	hud.update_score(score)
	
func _on_silver_panel_hit(paddle: Node) -> void:
	var panel_bonk = panel_hit_sfx.instantiate() 
	get_parent().add_child(panel_bonk)
	trigger_shake(12.0)
	print("silver panel hit")
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles_white(ball.global_position, hit_dir)
	# if panel_counter > 2:
		#destroy and explode anim
	# else: particle effect, sfx, and glitch effect (or just glitch effect randomized for its lifespan entirety)
	if ball_is_on_fire:
		score += 30
	else:
		score += 15
	
	hud.update_score(score)
	
func _silver_panel_destroyed() -> void:
	var panel_pop = panel_destroyed_sfx.instantiate() 
	get_parent().add_child(panel_pop)
	spawn_impact_particles_panel_pop(ball.global_position) #change to new color
	trigger_shake(15.0)
	score += 150
	panel_timer_1.start()
	
	
		
func _on_corner_hit(paddle: Node) -> void:
	var corner_bonk = corner_hit_sfx.instantiate()
	get_parent().add_child(corner_bonk)
	
	
	ball.base_speed *= 1.01 #was 1.03
	print("corner hit")
	# Spawn particles at impact
	var hit_dir: Vector2 = (ball.global_position - paddle.global_position).normalized()
	spawn_impact_particles(ball.global_position, hit_dir)
	
	if ball_is_on_fire:
		score += 10
	else:
		score += 5
	
	hud.update_score(score)
	
func _on_multiplier_hit(_multi: Node) -> void:
	trigger_zoom_punch(1.1, .75)
	score *= 2
	var multi_1_bonk = multi_connect_sfx.instantiate()
	get_parent().add_child(multi_1_bonk)
	var score_pop = score_dbl_popup.instantiate()
	
	get_parent().add_child(score_pop)
	#audio here, smash sfx and words (multiplier!)
	hud.update_score(score)
	print("multi hit")
	# Spawn particles at impact
	spawn_impact_particles_multiplier1(ball.global_position)
	for id in buff_ids:
		if id == barrier_id:
			var node := instance_from_id(id)
			if node:
				node.queue_free()
			
	
	
func _on_crystal_hit(_multi: Node) -> void:
	score += 25
	var crystal_1_bonk = crystal_hit_sfx.instantiate()
	get_parent().add_child(crystal_1_bonk)
	#audio here, smash sfx and words (multiplier!)
	hud.update_score(score)
	print("crystal hit")
	# Spawn particles at impact
	spawn_impact_particles_crystal1(ball.global_position)
	
func _on_fire_zone_entered() -> void:
	#fire stuff...boolean (ball_is_on_fire) to trigger double points on hits
	ball_is_on_fire = true
	ball_fire_timer.start()
	ball.enable_on_fire()
	#ball.method_that_shows_animation_until_a_timer_hides_it_again
	#use ballfiretimer to give the fireball a limited window
	
func _on_ice_zone_entered() -> void:
	ball_is_frozen = true
	ball_ice_timer.start()
	ball.enable_ice_cube()
	ball.base_speed *= .90
	
func reset_score() -> void:
	score = 0
	hud.update_score(score)
	
func is_game_active() -> bool:
	return game_started

func trigger_zoom_punch(scale_amount: float, duration: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	var target_zoom := Vector2.ONE * scale_amount

	tween.tween_property(cam, "zoom", target_zoom, duration * 0.5)
	tween.tween_property(cam, "zoom", Vector2.ONE, duration * 0.5)


		
func start_background_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.95, 2.0)
	tween.tween_property(bgnd_layer_2, "self_modulate:a", 0.10, 2.0)

func spawn_impact_particles(pos: Vector2, _dir_unused: Vector2) -> void:
	var p := impact_particles_scene.instantiate() as GPUParticles2D
	particles_root.add_child(p)

	var screen_center := get_viewport_rect().size * 0.5
	var to_center: Vector2 = (screen_center - pos).normalized()

	p.global_position = pos

	# 🔑 Godot 4 particles emit along -Y, so rotate by +90°
	p.global_rotation = to_center.angle() + PI / 2.0

	p.z_index = 100
	p.emitting = false
	p.emitting = true
	
func spawn_impact_particles_white(pos: Vector2, _dir_unused: Vector2) -> void:
	var p := impact_particles_white.instantiate() as GPUParticles2D
	particles_root.add_child(p)

	var screen_center := get_viewport_rect().size * 0.5
	var to_center: Vector2 = (screen_center - pos).normalized()

	p.global_position = pos

	# 🔑 Godot 4 particles emit along -Y, so rotate by +90°
	p.global_rotation = to_center.angle() + PI / 2.0

	p.z_index = 100
	p.emitting = false
	p.emitting = true
	
func spawn_multi_1() -> void:
	var multi1 := multiplier_1.instantiate()
	multi1.ball_hit_multiplier_1.connect(_on_multiplier_hit)
	get_parent().add_child(multi1)
	buff_ids.append(multi1.get_instance_id())
	var barrier := barriers.instantiate()
	get_parent().add_child(barrier)
	buff_ids.append(barrier.get_instance_id())
	barrier_id = barrier.get_instance_id()
	print_debug(barrier.get_instance_id())
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	multi1.global_position = Vector2(screen_center)
	barrier.global_position = Vector2(screen_center)
	ice_mine_timer.start()
	#work out ice_mine_timer and where it fits in with multi1 and minetimer
	
func spawn_score_crystal_1() -> void:
	var crystal1 := score_crystal_1.instantiate()
	crystal1.ball_hit_crystal_1.connect(_on_crystal_hit)
	get_parent().add_child(crystal1)
	buff_ids.append(crystal1.get_instance_id())
	var screen_size := get_viewport_rect().size
	var rndX = randf_range(50, screen_size.x - 50)
	var rndY = randf_range(50, screen_size.y - 50)
	crystal1.global_position = Vector2(rndX, rndY)
	
func spawn_fire_zone_1() -> void:
	var fire_1 := fire_zone.instantiate()
	fire_1.ball_on_fire.connect(_on_fire_zone_entered)
	get_parent().call_deferred("add_child", fire_1)
	buff_ids.append(fire_1.get_instance_id())
	trigger_shake(16.0)
	#trigger a zoom punch here too?
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	fire_1.global_position = Vector2(screen_center)
	
func spawn_ice_zone_1() -> void:
	var ice_1 := ice_zone.instantiate()
	ice_1.ball_on_ice.connect(_on_ice_zone_entered)
	get_parent().call_deferred("add_child", ice_1)
	buff_ids.append(ice_1.get_instance_id())
	trigger_shake(16.0)
	#trigger a zoom punch here too?
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	ice_1.global_position = Vector2(screen_center)
	
	
func spawn_mine_1() -> void:
	var mine_inst_1 := mine_1.instantiate()
	mine_inst_1.mine_exploded.connect(spawn_fire_zone_1)
	get_parent().add_child(mine_inst_1)
	buff_ids.append(mine_inst_1.get_instance_id())
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	mine_inst_1.global_position = Vector2(screen_center)
	multi1_timer.start()
	
func spawn_ice_mine_1() -> void:
	var ice_mine_inst_1 := ice_mine_1.instantiate()
	ice_mine_inst_1.mine_exploded.connect(spawn_ice_zone_1)
	get_parent().add_child(ice_mine_inst_1)
	buff_ids.append(ice_mine_inst_1.get_instance_id())
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	ice_mine_inst_1.global_position = Vector2(screen_center)
	mine_timer.start()
	
func spawn_silver_panel() -> void:
	var panel_1 := silver_panel_1.instantiate()
	get_parent().add_child(panel_1)
	panel_1.ball_hit_silver_panel.connect(_on_silver_panel_hit)
	panel_1.panel_pop.connect(_silver_panel_destroyed)
	panel_1.restarting.connect(_start_panel_1)
	buff_ids.append(panel_1.get_instance_id())
	var screen_size := get_viewport_rect().size
	var screen_center := screen_size * 0.5
	panel_1.global_position = Vector2(screen_center)
	


func spawn_impact_particles_multiplier1(pos: Vector2) -> void:
	var p := impact_particles_multiplier_1.instantiate() as GPUParticles2D
	particles_root.add_child(p)
	p.global_position = pos

	p.z_index = 100
	p.emitting = false
	p.emitting = true
	
func spawn_impact_particles_panel_pop(pos: Vector2) -> void:
	var p := impact_particles_panel_pop.instantiate() as GPUParticles2D
	particles_root.add_child(p)
	p.global_position = pos

	p.z_index = 100
	p.emitting = false
	p.emitting = true
	
func spawn_impact_particles_crystal1(pos: Vector2) -> void:
	var p := impact_particles_crystal_1.instantiate() as GPUParticles2D
	particles_root.add_child(p)
	p.global_position = pos

	p.z_index = 100
	p.emitting = false
	p.emitting = true


func _on_timer_timeout() -> void:
	spawn_multi_1()
	
func trigger_shake(amount: float) -> void:
	shake_strength = amount

func stop_all_timers() -> void:
	multi1_timer.stop()
	crystal1_timer.stop()
	mine_timer.stop()
	ice_mine_timer.stop()
	panel_timer_1.stop()
	
	
func clear_all_buffs() -> void:
	for id in buff_ids:
		if is_instance_id_valid(id):
			var node := instance_from_id(id)
			if node:
				node.queue_free()
	buff_ids.clear()

	#test this, see errors on game over? its thiss...
#need a method to clear all buffs
#each buff: needs a spinning anim, an entry anim, and a shatter/break/disintegrate anim
#follow multi1 template on incorporating
	
func _start_panel_1() -> void:
	panel_timer_1.start()
	print_debug("restarting now panel 1")

func _on_crystal_timer_timeout() -> void:
	spawn_score_crystal_1()


func _on_level_music_finished() -> void:
	level_music.play()


func _on_ball_fire_timer_timeout() -> void:
	ball_is_on_fire = false
	#this times up with the ball timer to hide the fire animation


func _on_mine_timer_timeout() -> void:
	spawn_mine_1()


func _on_ice_mine_timer_timeout() -> void:
	spawn_ice_mine_1()


func _on_panel_timer_1_timeout() -> void:
	spawn_silver_panel()
	
func _on_score_button_pressed(player_name: String) -> void:
	print("Submitting final score:", final_score_to_submit, "as", player_name)
	hud.hide_score_submit()

	var ok = await LeaderboardService.submit_score_with_name_best_effort(player_name, final_score_to_submit)
	print("Submit finished:", ok)

	LeaderboardService.fetch_top_best_effort(func(records: Array, ok_fetch: bool, err: String) -> void:
		hud.show_leaderboard(records, ok_fetch, err)
	)

	_play_again()
	
func _play_again() -> void:
	await get_tree().create_timer(3.0).timeout
	awaiting_score_submit = false
	hud.show_start_message("Play Again?")
