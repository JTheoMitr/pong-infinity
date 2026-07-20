extends Node

signal neurobits_changed(new_amount: int)
signal ball_purchased(ball_id: String)
signal ball_equipped(ball_id: String)

const SAVE_PATH: String = "user://player_save.cfg"

var neurobits: int = 0
var xp_toward_next_neurobit: int = 0

var owned_balls: Array[String] = [
	BallCatalog.DEFAULT_BALL_ID
]

var equipped_ball_id: String = BallCatalog.DEFAULT_BALL_ID


func _ready() -> void:
	load_save()


func load_save() -> void:
	var config := ConfigFile.new()
	var error: Error = config.load(SAVE_PATH)

	if error != OK:
		create_default_save()
		save()
		return

	neurobits = int(
		config.get_value("currency", "neurobits", 0)
	)
	
	xp_toward_next_neurobit = int(
		config.get_value(
			"currency",
			"xp_toward_next_neurobit",
			0
		)
	)

	var saved_owned_balls: Variant = config.get_value(
		"inventory",
		"owned_balls",
		[BallCatalog.DEFAULT_BALL_ID]
	)

	owned_balls.clear()

	if saved_owned_balls is Array:
		for saved_id: Variant in saved_owned_balls:
			var ball_id := str(saved_id)

			if (
				BallCatalog.has_ball(ball_id)
				and not owned_balls.has(ball_id)
			):
				owned_balls.append(ball_id)

	if not owned_balls.has(BallCatalog.DEFAULT_BALL_ID):
		owned_balls.push_front(BallCatalog.DEFAULT_BALL_ID)

	equipped_ball_id = str(
		config.get_value(
			"inventory",
			"equipped_ball_id",
			BallCatalog.DEFAULT_BALL_ID
		)
	)

	if not owns_ball(equipped_ball_id):
		equipped_ball_id = BallCatalog.DEFAULT_BALL_ID


func save() -> bool:
	var config := ConfigFile.new()

	config.set_value("currency", "neurobits", neurobits)
	config.set_value("inventory", "owned_balls", owned_balls)
	config.set_value(
		"inventory",
		"equipped_ball_id",
		equipped_ball_id
	)

	var error: Error = config.save(SAVE_PATH)
	
	config.set_value(
		"currency",
		"xp_toward_next_neurobit",
		xp_toward_next_neurobit
	)

	if error != OK:
		push_error(
			"Failed to save player data: %s"
			% error_string(error)
		)
		return false

	return true


func create_default_save() -> void:
	neurobits = 0
	xp_toward_next_neurobit = 0
	owned_balls = [BallCatalog.DEFAULT_BALL_ID]
	equipped_ball_id = BallCatalog.DEFAULT_BALL_ID


func owns_ball(ball_id: String) -> bool:
	return owned_balls.has(ball_id)


func purchase_ball(ball_id: String) -> bool:
	if not BallCatalog.has_ball(ball_id):
		push_warning("Unknown shop ball: %s" % ball_id)
		return false

	if owns_ball(ball_id):
		print("%s is already owned." % ball_id)
		return true

	var ball_data: Dictionary = BallCatalog.get_ball(ball_id)
	var price: int = int(ball_data.get("price", 0))

	if neurobits < price:
		print(
			"Not enough Neurobits. Need %d, have %d."
			% [price, neurobits]
		)
		return false

	neurobits -= price
	owned_balls.append(ball_id)

	save()

	neurobits_changed.emit(neurobits)
	ball_purchased.emit(ball_id)

	print(
		"Neuroball purchased: %s | Remaining Neurobits: %d"
		% [ball_id, neurobits]
	)

	return true


func equip_ball(ball_id: String) -> bool:
	if not BallCatalog.has_ball(ball_id):
		return false

	if not owns_ball(ball_id):
		return false

	equipped_ball_id = ball_id
	save()

	ball_equipped.emit(ball_id)

	return true


func add_neurobits(amount: int) -> void:
	if amount <= 0:
		return

	neurobits += amount
	save()

	neurobits_changed.emit(neurobits)
	
func add_xp(amount: int) -> int:
	if amount <= 0:
		return 0

	xp_toward_next_neurobit += amount

	var earned_neurobits: int = xp_toward_next_neurobit / 100
	xp_toward_next_neurobit %= 100

	if earned_neurobits > 0:
		neurobits += earned_neurobits
		neurobits_changed.emit(neurobits)

	save()

	print(
		"XP added: %d | Neurobits earned: %d | Total Neurobits: %d | XP progress: %d/100"
		% [
			amount,
			earned_neurobits,
			neurobits,
			xp_toward_next_neurobit
		]
	)

	return earned_neurobits
