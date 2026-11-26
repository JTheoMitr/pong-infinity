class_name TableCatalog
extends RefCounted

const DEFAULT_TABLE_ID: String = "classic_green"

const TABLE_PREVIEW_FRAMES: SpriteFrames = preload(
	"res://tables/table_previews.tres"
)

const TABLES: Dictionary = {
	"classic_green": {
		"display_name": "Classic",
		"price": 0,
		"scene": preload(
			"res://tables/classic_green.tscn"
		),
		"shop_preview": TABLE_PREVIEW_FRAMES,
		"preview_animation": "classic_green",
	},

	"deep_space": {
		"display_name": "Space",
		"price": 200,
		"scene": preload(
			"res://tables/deep_space.tscn"
		),
		"shop_preview": TABLE_PREVIEW_FRAMES,
		"preview_animation": "deep_space"
	},
	
	"sunset": {
		"display_name": "Sunset",
		"price": 200,
		"scene": preload("res://tables/sunset.tscn"
		),
		"shop_preview": TABLE_PREVIEW_FRAMES,
		"preview_animation": "sunset",
	},
	
	"abyss": {
	"display_name": "Ocean",
	"price": 200,
	"scene": preload(
		"res://tables/abyss.tscn"
	),
	"shop_preview": TABLE_PREVIEW_FRAMES,
	"preview_animation": "abyss"
	},
	
	"megacity": {
	"display_name": "Megacity",
	"price": 200,
	"scene": preload("res://tables/megacity.tscn"),
	"shop_preview": TABLE_PREVIEW_FRAMES,
	"preview_animation": "megacity"
	},
}


static func has_table(table_id: String) -> bool:
	return TABLES.has(table_id)


static func get_table(table_id: String) -> Dictionary:
	if TABLES.has(table_id):
		return TABLES[table_id]

	return TABLES[DEFAULT_TABLE_ID]


static func get_table_ids() -> Array[String]:
	var result: Array[String] = []

	for table_id: Variant in TABLES.keys():
		result.append(str(table_id))

	return result

static func get_shop_preview(table_id: String) -> SpriteFrames:
	var table_data: Dictionary = get_table(table_id)
	return table_data.get("shop_preview") as SpriteFrames
