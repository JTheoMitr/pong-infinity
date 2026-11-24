extends Node

signal neurobits_changed(new_amount: int)
signal ball_purchased(ball_id: String)
signal ball_equipped(ball_id: String)

signal table_purchased(table_id: String)
signal table_equipped(table_id: String)

const SAVE_PATH: String = "user://player_save.cfg"

var neurobits: int = 0
var xp_toward_next_neurobit: int = 0
var enter_shop_from_arcade: bool = false
var rounds_played: int = 0
var returning_to_main_menu_from_shop: bool = false
var returning_to_main_menu_from_game: bool = false


var owned_balls: Array[String] = [
	BallCatalog.DEFAULT_BALL_ID
]

var equipped_ball_id: String = BallCatalog.DEFAULT_BALL_ID

var owned_tables: Array[String] = [
	TableCatalog.DEFAULT_TABLE_ID
]

var equipped_table_id: String = TableCatalog.DEFAULT_TABLE_ID

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

	rounds_played = int(
		config.get_value(
			"stats",
			"rounds_played",
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
	
	var saved_owned_tables: Variant = config.get_value(
		"inventory",
		"owned_tables",
		[TableCatalog.DEFAULT_TABLE_ID]
	)

	owned_tables.clear()

	if saved_owned_tables is Array:
		for saved_id: Variant in saved_owned_tables:
			var table_id := str(saved_id)

			if (
				TableCatalog.has_table(table_id)
				and not owned_tables.has(table_id)
			):
				owned_tables.append(table_id)

	if not owned_tables.has(TableCatalog.DEFAULT_TABLE_ID):
		owned_tables.push_front(TableCatalog.DEFAULT_TABLE_ID)

	equipped_table_id = str(
		config.get_value(
			"inventory",
			"equipped_table_id",
			TableCatalog.DEFAULT_TABLE_ID
		)
	)

	if not owns_table(equipped_table_id):
		equipped_table_id = TableCatalog.DEFAULT_TABLE_ID
		
		# TEMPORARY: Unlock Deep Space for development.
	if not owned_tables.has("deep_space"):
		owned_tables.append("deep_space")
		save()
		
	# TEMPORARY: Development table unlocks.
	#var inventory_changed := false
#
	#for table_id: String in ["deep_space", "sunset"]:
		#if not owned_tables.has(table_id):
			#owned_tables.append(table_id)
			#inventory_changed = true
#
	#if inventory_changed:
		#save()
		
		
func save() -> bool:
	var config := ConfigFile.new()

	config.set_value(
		"currency",
		"neurobits",
		neurobits
	)

	config.set_value(
		"currency",
		"xp_toward_next_neurobit",
		xp_toward_next_neurobit
	)

	config.set_value(
		"inventory",
		"owned_balls",
		owned_balls
	)

	config.set_value(
		"inventory",
		"equipped_ball_id",
		equipped_ball_id
	)
	
	config.set_value(
		"stats",
		"rounds_played",
		rounds_played
	)
	
	config.set_value(
		"inventory",
		"owned_tables",
		owned_tables
	)

	config.set_value(
		"inventory",
		"equipped_table_id",
		equipped_table_id
	)
	var error: Error = config.save(SAVE_PATH)

	if error != OK:
		push_error(
			"Failed to save player data: %s"
			% error_string(error)
		)
		return false

	return true


func create_default_save() -> void:
	neurobits = 0
	rounds_played = 0
	xp_toward_next_neurobit = 0
	owned_balls = [BallCatalog.DEFAULT_BALL_ID]
	equipped_ball_id = BallCatalog.DEFAULT_BALL_ID
	owned_tables = [TableCatalog.DEFAULT_TABLE_ID]
	equipped_table_id = TableCatalog.DEFAULT_TABLE_ID

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
	
	@warning_ignore("integer_division")
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

func record_completed_round() -> void:
	rounds_played += 1
	save()

	print("Rounds played: ", rounds_played)

func owns_table(table_id: String) -> bool:
	return owned_tables.has(table_id)


func purchase_table(table_id: String) -> bool:
	if not TableCatalog.has_table(table_id):
		push_warning("Unknown shop table: %s" % table_id)
		return false

	if owns_table(table_id):
		print("%s is already owned." % table_id)
		return true

	var table_data: Dictionary = TableCatalog.get_table(table_id)
	var price: int = int(table_data.get("price", 0))

	if neurobits < price:
		print(
			"Not enough Neurobits. Need %d, have %d."
			% [price, neurobits]
		)
		return false

	neurobits -= price
	owned_tables.append(table_id)

	if not save():
		neurobits += price
		owned_tables.erase(table_id)
		return false

	neurobits_changed.emit(neurobits)
	table_purchased.emit(table_id)

	print(
		"Table purchased: %s | Remaining Neurobits: %d"
		% [table_id, neurobits]
	)

	return true


func equip_table(table_id: String) -> bool:
	if not TableCatalog.has_table(table_id):
		return false

	if not owns_table(table_id):
		return false

	var previous_table_id: String = equipped_table_id
	equipped_table_id = table_id

	if not save():
		equipped_table_id = previous_table_id
		return false

	table_equipped.emit(table_id)

	return true
