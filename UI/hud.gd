# res://Scripts/hud.gd
extends CanvasLayer

@onready var label: Label = $CenterContainer/VBoxContainer/Label
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var countdown_label: Label = $CountdownLabel
@onready var pause_label: Label = $PauseLabel
@onready var center_container = $CenterContainer
@onready var score_label: Label = $ScoreLabel

@onready var leaderboard_panel: Control = $LeaderboardPanel
@onready var leaderboard_rows: VBoxContainer = $LeaderboardPanel/VBox/Rows
@onready var leaderboard_status: Label = $LeaderboardPanel/VBox/Status
@onready var leaderboard_title: Label = $LeaderboardPanel/VBox/Title

@onready var name_entry = $LeaderboardPanel/NameEntry
@onready var score_submit_button = $LeaderboardPanel/SubmitButton

signal start_button_pressed
signal submit_score_button_pressed(player_name: String)


func _ready() -> void:
	label.text = "RICOCHET"
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

func show_start_message(text: String) -> void: #gives the start button back to player
	label.text = text #customize for each call
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
	
func show_score() -> void:
	score_label.visible = true
	
func hide_score() -> void:
	score_label.visible = false
	
func _clear_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()
		
func show_leaderboard(records: Array, ok: bool, _err: String) -> void:
	leaderboard_panel.visible = true
	leaderboard_title.text = "TOP 10"

	_clear_children(leaderboard_rows)

	if not ok:
		leaderboard_status.visible = true
		leaderboard_status.text = "Leaderboard unavailable (offline)"
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
		row.text = "%d. %s  —  %d" % [rank, name, score]
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		leaderboard_rows.add_child(row)

func hide_leaderboard() -> void:
	leaderboard_panel.visible = false
	
func show_score_submit() -> void:
	name_entry.show()
	name_entry.grab_focus()
	score_submit_button.show()
	
func hide_score_submit() -> void:
	name_entry.hide()
	score_submit_button.hide() #make sure to call this properly and check flow, start button never shows offline


func _on_submit_button_pressed() -> void:
	if name_entry.text != "":
		emit_signal("submit_score_button_pressed", name_entry.text.strip_edges())
