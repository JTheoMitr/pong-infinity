class_name BallCatalog
extends RefCounted

const DEFAULT_BALL_ID: String = "neuroball"

const BALLS: Dictionary = {
	"neuroball": {
		"display_name": "NEUROBALL",
		"price": 0,
		"sprite_frames": preload(
			"res://models/original_ball/original_ball.tres"
		)
	},

	"eyeball": {
		"display_name": "...............Eyeball",
		"price": 100,
		"sprite_frames": preload(
			"res://models/eyeball/eyeball.tres"
		)
	},

	"burger_ball": {
		"display_name": "..................Burger",
		"price": 250,
		"sprite_frames": preload(
			"res://models/burger/burger.tres"
		)
	},

	"saturn": {
		"display_name": "..................Saturn",
		"price": 500,
		"sprite_frames": preload(
			"res://models/saturn/saturn.tres"
		)
	},
	
	"sushi": {
		"display_name": "..................Sushi",
		"price": 1,
		"sprite_frames": preload(
			"res://models/sushi/sushi.tres"
		)
	},
}


static func has_ball(ball_id: String) -> bool:
	return BALLS.has(ball_id)


static func get_ball(ball_id: String) -> Dictionary:
	if BALLS.has(ball_id):
		return BALLS[ball_id]

	return BALLS[DEFAULT_BALL_ID]


static func get_ball_ids() -> Array[String]:
	var result: Array[String] = []

	for ball_id: Variant in BALLS.keys():
		result.append(str(ball_id))

	return result
