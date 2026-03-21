# res://Scripts/hud.gd
extends CanvasLayer

@onready var label: Label = $CenterContainer/VBoxContainer/Label
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var countdown_label: Label = $CountdownLabel
@onready var pause_label: Label = $PauseLabel
@onready var center_container = $CenterContainer
@onready var score_label: Label = $ScoreLabel
@onready var controller_sprite = $ControllerSprite

@onready var leaderboard_panel: Control = $LeaderboardPanel
@onready var leaderboard_rows: VBoxContainer = $LeaderboardPanel/VBox/Rows
@onready var leaderboard_status: Label = $LeaderboardPanel/VBox/Status
@onready var leaderboard_title: Label = $LeaderboardPanel/VBox/Title

@onready var name_entry = $LeaderboardPanel/VBoxContainer/NameEntry
@onready var score_submit_button = $LeaderboardPanel/VBoxContainer/SubmitButton
@onready var no_submit_button = $LeaderboardPanel/VBoxContainer/SubmitButton2
@onready var resume_button = $PauseLabel/ResumeButton
@onready var submit_message = $LeaderboardPanel/SubmitMessage
@onready var submit_panel = $LeaderboardPanel/SubmitPanel
@onready var quit_button = $LeaderboardPanel/VBoxContainer/QuitButton
@onready var music_button = $PauseLabel/MusicButton

var custom_font = load("res://Assets/Fonts/PixelTandysoft-0rJG.ttf")
var musicOn = true


signal start_button_pressed
signal submit_score_button_pressed(player_name: String)
signal resume_button_pressed
signal no_submit_play_again_pressed
signal music_button_pressed


func _ready() -> void:
	label.text = "RICOCHET"
	label.visible = true
	countdown_label.visible = false
	start_button.visible = true
	pause_label.visible = false
	score_label.visible = false
	start_button.pressed.connect(_on_start_button_pressed)
	submit_message.visible = false
	submit_panel.visible = false
	


func _on_start_button_pressed() -> void:
	start_button.visible = false
	label.visible = false
	countdown_label.visible = true
	emit_signal("start_button_pressed")
	

func show_pause_overlay(paused: bool) -> void:
	pause_label.visible = paused
	score_label.visible = paused
	if pause_label.visible:
		resume_button.grab_focus()

func show_start_message(text: String) -> void: #gives the start button back to player
	label.text = text #customize for each call
	label.visible = true
	start_button.visible = true
	countdown_label.visible = false
	
func show_first_start_message(text: String) -> void: #gives the start button back to player
	label.text = text #customize for each call
	label.visible = true
	start_button.visible = true
	countdown_label.visible = false
	controller_sprite.show()


func hide_start_message() -> void:
	label.visible = false
	start_button.visible = false
	countdown_label.visible = false
	if controller_sprite.visible == true:
		controller_sprite.hide()
		#print("hide controller")


func show_countdown(number: int) -> void:
	countdown_label.text = str(number)
	countdown_label.visible = true


func hide_countdown() -> void:
	countdown_label.visible = false
	
func update_score(value: int) -> void:
	score_label.text = "Score: " + str(value)
	
func show_score() -> void:
	score_label.visible = true
	
func hide_score() -> void:
	score_label.visible = false
	
func _clear_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()
		
func show_leaderboard(records: Array, ok: bool, _err: String) -> void:
	leaderboard_panel.visible = true
	leaderboard_title.text = "\n TOP 10"

	_clear_children(leaderboard_rows)

	if not ok:
		leaderboard_status.visible = true
		leaderboard_status.text = "\n Leaderboard unavailable (offline)"
		score_submit_button.hide()
		quit_button.hide()
		name_entry.hide()
		await get_tree().create_timer(3.0).timeout
		show_start_message("Play Again?")
		start_button.grab_focus()
		
	else:
		leaderboard_status.visible = false
		leaderboard_status.text = ""

	if records.is_empty():
		leaderboard_status.visible = true
		leaderboard_status.text = "No scores yet" if ok else "Leaderboard unavailable (offline)"
		return

	for rec in records:
		var rank: int = int(rec.get("rank", 0))
		var name: String = str(rec.get("username", "unknown"))
		var score: int = int(rec.get("score", 0))

		var row := Label.new()
		row.add_theme_font_override("font", custom_font)
		row.text = "%d. %s  —  %d" % [rank, name, score]
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		leaderboard_rows.add_child(row)

func hide_leaderboard() -> void:
	leaderboard_panel.visible = false
	
func show_score_submit() -> void:
	submit_panel.show()
	name_entry.show()
	name_entry.grab_focus()
	score_submit_button.show()
	no_submit_button.show()
	quit_button.show()
	
func hide_score_submit() -> void:
	name_entry.hide()
	score_submit_button.hide() #make sure to call this properly and check flow, start button never shows offline
	no_submit_button.hide()
	quit_button.hide()

func _on_submit_button_pressed() -> void:
	if name_entry.text != "":
		emit_signal("submit_score_button_pressed", name_entry.text.strip_edges())
	submit_message.show()
	await get_tree().create_timer(2.0).timeout
	submit_message.hide()
	submit_panel.hide()


func _on_resume_button_pressed() -> void:
	emit_signal("resume_button_pressed")


func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_submit_button_2_pressed() -> void:
	emit_signal("no_submit_play_again_pressed")


func _on_music_button_pressed() -> void:
	emit_signal("music_button_pressed")

func music_button_text(text: String) -> void:
	music_button.text = text
