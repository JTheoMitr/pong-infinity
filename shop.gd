extends Node3D

const SHOP_BALL_IDS: Array[String] = [
	"sushi",
	"burger_ball",
	"saturn",
	"eyeball"
]

var pending_equip_ball_id: String = ""

enum CameraZone {
	SHOP,
	GAME,
	PATIO,
	CABINET
}

@onready var camera: Camera3D = $Camera3D
@onready var camera_start: Marker3D = $CameraStart
@onready var camera_shop_view: Marker3D = $CameraShopView
@onready var shop_ui: CanvasLayer = $CanvasLayer
@onready var nb_lbl: Label = $CanvasLayer/NBLabel

@onready var screen_quad: MeshInstance3D = $ScreenQuad
@onready var screen_viewport: SubViewport = $ScreenQuad/ScreenViewport
@onready var color_rect: ColorRect = $ScreenQuad/ScreenViewport/ColorRect
@onready var vendor_sprite: Sprite3D = $Monitor/Vendor
@onready var vendor_anim: AnimatedTexture = vendor_sprite.texture
@onready var vendor_voice_intro: AudioStreamPlayer = $VendorVoiceIntro

@onready var camera_corner: Marker3D = $CameraCorner
@onready var camera_game_view: Marker3D = $CameraGameView
@onready var camera_cabinet: Marker3D = $CameraCabinet
@onready var camera_smoker: Marker3D = $CameraSmoker

@onready var fade_cover: ColorRect = $CanvasLayer/FadeCover
@onready var loading_icon: RichTextLabel = $CanvasLayer/LoadingIcon

@onready var button_1: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer/Label
@onready var button_2: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer2/Label
@onready var button_3: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer3/Label
@onready var button_4: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer4/Label

@onready var price_1: RichTextLabel = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer/RichTextLabel
@onready var price_2: RichTextLabel = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer2/RichTextLabel
@onready var price_3: RichTextLabel = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer3/RichTextLabel
@onready var price_4: RichTextLabel = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer4/RichTextLabel

@onready var dialogue_ui: Control = $CanvasLayer/DialogueUI

@onready var shop_screen_hitbox: Area3D = $ScreenQuad/ShopScreenHitbox

@onready var purchase_popup: Control = (
	$ScreenQuad/ScreenViewport/PurchasePopup
)

@onready var purchase_message: RichTextLabel = (
	$ScreenQuad/ScreenViewport/PurchasePopup/Panel/VBoxContainer/MessageLabel
)

@onready var purchase_yes: Label = (
	$ScreenQuad/ScreenViewport/PurchasePopup/Panel/VBoxContainer/YesLabel
)

@onready var purchase_no: Label = (
	$ScreenQuad/ScreenViewport/PurchasePopup/Panel/VBoxContainer/NoLabel
)

enum PurchasePopupState {
	CLOSED,
	CONFIRM_PURCHASE,
	ALREADY_OWNED,
	PURCHASED
}

var purchase_popup_state: PurchasePopupState = PurchasePopupState.CLOSED
var purchase_popup_index: int = 0
var pending_purchase_ball_id: String = ""

var camera_moving: bool = false
var camera_zone: CameraZone = CameraZone.SHOP

var selected_index := 0
var row_labels: Array[Label] = []
var price_labels: Array[RichTextLabel] = []


func _ready() -> void:
	nb_lbl.visible = false
	purchase_popup.hide()

	print("Currently equipped: ", SaveManager.equipped_ball_id)

	show_loading_cover()
	dialogue_ui.hide()

	row_labels = [
		button_1,
		button_2,
		button_3,
		button_4
	]

	price_labels = [
		price_1,
		price_2,
		price_3,
		price_4
	]

	refresh_shop_labels()

	print("Neurobits: ", SaveManager.neurobits)
	print("Owned balls: ", SaveManager.owned_balls)
	print("Equipped ball: ", SaveManager.equipped_ball_id)

	screen_viewport.transparent_bg = false
	screen_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	screen_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS

	color_rect.position = Vector2.ZERO

	await RenderingServer.frame_post_draw

	var screen_mat := ShaderMaterial.new()
	screen_mat.shader = preload("res://crt_screen_3d.gdshader")
	screen_mat.set_shader_parameter("screen_texture", screen_viewport.get_texture())
	screen_quad.material_override = screen_mat

	var vendor_mat := ShaderMaterial.new()
	vendor_mat.shader = preload("res://crt_screen_3d.gdshader")
	vendor_mat.set_shader_parameter("screen_texture", vendor_sprite.texture)
	vendor_sprite.material_override = vendor_mat

	vendor_anim.pause = true
	vendor_anim.current_frame = 3

	var returning_from_arcade: bool = SaveManager.enter_shop_from_arcade

	SaveManager.enter_shop_from_arcade = false

	if returning_from_arcade:
		camera.global_position = camera_cabinet.global_position
		camera.global_rotation = camera_cabinet.global_rotation
		camera_zone = CameraZone.CABINET
	else:
		camera.global_position = camera_start.global_position
		camera.global_rotation = camera_start.global_rotation
		camera_zone = CameraZone.SHOP

	camera.current = true

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	await hide_loading_cover()

	await get_tree().create_timer(0.5).timeout

	if returning_from_arcade:
		await exit_cabinet_to_game_view()
	else:
		await enter_shop()


func _input(event: InputEvent) -> void:
	if camera_zone != CameraZone.SHOP:
		return

	if camera_moving:
		return

	if purchase_popup_state != PurchasePopupState.CLOSED:
		if event is InputEventMouseMotion:
			_try_hover_purchase_popup(event.position)

		elif (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			_try_click_purchase_popup(event.position)

		return

	if event is InputEventMouseMotion:
		_try_hover_shop_item(event.position)

	elif (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		_try_select_shop_item_with_mouse(event.position)


func _unhandled_input(event: InputEvent) -> void:
	if purchase_popup_state != PurchasePopupState.CLOSED:
		_handle_purchase_popup_input(event)
		return

	if camera_moving:
		return

	if event.is_action_pressed("ui_paddle_rotate_clockwise"):
		await rotate_clockwise()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_paddle_rotate_counterclockwise"):
		await rotate_counterclockwise()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_down"):
		selected_index = min(selected_index + 1, row_labels.size() - 1)
		_update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_up"):
		selected_index = max(selected_index - 1, 0)
		_update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		match camera_zone:
			CameraZone.SHOP:
				get_viewport().set_input_as_handled()
				handle_shop_accept()

			CameraZone.GAME:
				get_viewport().set_input_as_handled()
				launch_game_from_cabinet()


func rotate_clockwise() -> void:
	match camera_zone:
		CameraZone.SHOP:
			await move_to_game_view()

		CameraZone.GAME:
			await move_to_patio()

		CameraZone.PATIO:
			pass


func rotate_counterclockwise() -> void:
	match camera_zone:
		CameraZone.PATIO:
			await move_back_to_game_view_from_patio()

		CameraZone.GAME:
			await move_back_to_shop()

		CameraZone.SHOP:
			pass


func enter_shop() -> void:
	camera_moving = true

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera, "global_position", camera_shop_view.global_position, 2.5)
	tween.parallel().tween_property(camera, "global_rotation", camera_shop_view.global_rotation, 2.5)

	await tween.finished

	camera_zone = CameraZone.SHOP
	camera_moving = false

	var nbits = SaveManager.neurobits
	nb_lbl.text = "Neurobits: " + str(nbits)
	nb_lbl.visible = true

	await play_vendor_intro()
	shop_ui.visible = true


func move_to_game_view() -> void:
	camera_moving = true
	set_screen_animation_active(false)
	nb_lbl.visible = false

	await tween_camera_to_marker(camera_corner, 1.4)
	await tween_camera_to_marker(camera_game_view, 2.5)

	camera_zone = CameraZone.GAME
	camera_moving = false


func move_to_patio() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_smoker, 3.0)

	camera_zone = CameraZone.PATIO
	camera_moving = false

	show_patio_dialogue()


func move_back_to_game_view_from_patio() -> void:
	camera_moving = true
	dialogue_ui.hide()

	await tween_camera_to_marker(camera_game_view, 3.0)

	camera_zone = CameraZone.GAME
	camera_moving = false


func move_back_to_shop() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_corner, 2.5)
	await tween_camera_to_marker(camera_shop_view, 1.4)

	camera_zone = CameraZone.SHOP
	camera_moving = false

	var nbits = SaveManager.neurobits
	nb_lbl.text = "Neurobits: " + str(nbits)
	nb_lbl.visible = true

	set_screen_animation_active(true)


func move_into_cabinet() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_cabinet, 5.0)

	camera_moving = false
	camera_zone = CameraZone.CABINET


func launch_game_from_cabinet() -> void:
	var scene_path := "res://main_menu.tscn"

	ResourceLoader.load_threaded_request(scene_path)

	await move_into_cabinet()

	set_screen_animation_active(false)

	var status := ResourceLoader.load_threaded_get_status(scene_path)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene := ResourceLoader.load_threaded_get(scene_path) as PackedScene
		get_tree().change_scene_to_packed(packed_scene)
	else:
		get_tree().change_scene_to_file(scene_path)


func tween_camera_to_marker(marker: Marker3D, duration: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera, "global_position", marker.global_position, duration)
	tween.parallel().tween_property(camera, "global_rotation", marker.global_rotation, duration)

	await tween.finished


func _update_selection() -> void:
	for i in range(row_labels.size()):
		if i == selected_index:
			row_labels[i].text = "> " + row_labels[i].text.trim_prefix("> ")
			row_labels[i].modulate = Color(1.0, 0.667, 0.0, 1.0)
		else:
			row_labels[i].text = row_labels[i].text.trim_prefix("> ")
			row_labels[i].modulate = Color(0.0, 0.918, 1.0, 1.0)


func play_vendor_intro() -> void:
	await get_tree().create_timer(0.2).timeout

	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	vendor_voice_intro.play()
	set_screen_animation_active(true)

	await get_tree().create_timer(1.0).timeout

	vendor_anim.pause = true
	vendor_anim.current_frame = 3

	await get_tree().create_timer(1.1).timeout

	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	await get_tree().create_timer(1.3).timeout

	vendor_anim.pause = true
	vendor_anim.current_frame = 3


func set_screen_animation_active(active: bool) -> void:
	if active:
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func show_loading_cover() -> void:
	fade_cover.visible = true
	fade_cover.modulate.a = 1.0

	loading_icon.visible = true
	loading_icon.modulate.a = 1.0


func hide_loading_cover() -> void:
	await get_tree().create_timer(0.75, false, false, true).timeout

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	tween.tween_property(fade_cover, "modulate:a", 0.0, 0.8)
	tween.tween_property(loading_icon, "modulate:a", 0.0, 0.8)

	await tween.finished

	loading_icon.visible = false
	fade_cover.visible = false


func show_patio_dialogue() -> void:
	dialogue_ui.visible = true


func handle_shop_accept() -> void:
	if selected_index < 0 or selected_index >= SHOP_BALL_IDS.size():
		return

	var ball_id: String = SHOP_BALL_IDS[selected_index]

	if SaveManager.owns_ball(ball_id):
		_show_already_owned_popup(ball_id)
		return

	_show_purchase_confirmation(ball_id)


func refresh_shop_labels() -> void:
	var nbits = SaveManager.neurobits
	nb_lbl.text = "Neurobits: " + str(nbits)

	for index in range(row_labels.size()):
		if index >= SHOP_BALL_IDS.size():
			continue

		var ball_id: String = SHOP_BALL_IDS[index]
		var ball_data: Dictionary = BallCatalog.get_ball(ball_id)

		var display_name: String = str(
			ball_data.get("display_name", "BALL")
		)

		price_labels[index].visible = !SaveManager.owns_ball(ball_id)

		var status_text: String

		if SaveManager.owns_ball(ball_id):
			status_text = "..............[OWNED]"
		else:
			status_text = ".............." + display_name

		row_labels[index].text = status_text

	_update_selection()


func exit_cabinet_to_game_view() -> void:
	camera_moving = true
	nb_lbl.visible = false
	dialogue_ui.hide()
	set_screen_animation_active(false)

	await tween_camera_to_marker(camera_game_view, 5.0)

	camera_zone = CameraZone.GAME
	camera_moving = false


func _try_select_shop_item_with_mouse(mouse_position: Vector2) -> void:
	print("Shop click detected at: ", mouse_position)

	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * 1000.0
	)

	query.collision_mask = 1
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		print("Ray hit NOTHING")
		return

	print(
		"Ray hit: ",
		result["collider"].name,
		" at ",
		result["position"]
	)

	if result["collider"] != shop_screen_hitbox:
		print("Hit something other than ShopScreenHitbox")
		return

	var hit_position: Vector3 = result["position"]

	_select_shop_row_from_world_position(hit_position)


func _select_shop_row_from_world_position(
	hit_position: Vector3
) -> void:
	var quad := screen_quad.mesh as QuadMesh

	if quad == null:
		return

	var local_hit: Vector3 = screen_quad.to_local(hit_position)
	var quad_size: Vector2 = quad.size

	var uv := Vector2(
		(local_hit.x / quad_size.x) + 0.5,
		0.5 - (local_hit.y / quad_size.y)
	)

	if (
		uv.x < 0.0
		or uv.x > 1.0
		or uv.y < 0.0
		or uv.y > 1.0
	):
		return

	var viewport_position := Vector2(
		uv.x * screen_viewport.size.x,
		uv.y * screen_viewport.size.y
	)

	_select_shop_row_at_viewport_position(viewport_position)


func _select_shop_row_at_viewport_position(
	viewport_position: Vector2
) -> void:
	for i in range(row_labels.size()):
		var label: Label = row_labels[i]

		var label_rect := Rect2(
			label.global_position,
			label.size
		)

		if label_rect.has_point(viewport_position):
			selected_index = i
			_update_selection()

			print(
				"Mouse selected shop item: ",
				SHOP_BALL_IDS[selected_index]
			)

			screen_viewport.render_target_update_mode = (
				SubViewport.UPDATE_ONCE
			)

			handle_shop_accept()
			return


func _show_purchase_confirmation(ball_id: String) -> void:
	var ball_data: Dictionary = BallCatalog.get_ball(ball_id)

	var display_name: String = str(
		ball_data.get("display_name", "NEUROBALL")
	)

	var price: int = int(
		ball_data.get("price", 0)
	)

	pending_purchase_ball_id = ball_id
	purchase_popup_state = PurchasePopupState.CONFIRM_PURCHASE
	purchase_popup_index = 0

	purchase_message.text = (
		"ARE YOU SURE YOU WANT TO PURCHASE\n"
		+ display_name
		+ "?\n\n"
		+ "COST: %d NEUROBITS" % price
	)

	purchase_yes.text = "YES"
	purchase_no.text = "NO"

	purchase_yes.show()
	purchase_no.show()
	purchase_popup.show()

	_update_purchase_popup_selection()
	set_screen_animation_active(true)


func _show_already_owned_popup(ball_id: String) -> void:
	var ball_data: Dictionary = BallCatalog.get_ball(ball_id)

	var display_name: String = str(
		ball_data.get("display_name", "NEUROBALL")
	)

	purchase_popup_state = PurchasePopupState.ALREADY_OWNED
	pending_purchase_ball_id = ""

	purchase_message.text = (
		display_name
		+ "\n\nALREADY OWNED"
	)

	purchase_yes.text = "OK"
	purchase_yes.show()
	purchase_no.hide()

	purchase_popup_index = 0
	purchase_popup.show()

	_update_purchase_popup_selection()
	set_screen_animation_active(true)


func _update_purchase_popup_selection() -> void:
	var labels: Array[Label] = [
		purchase_yes,
		purchase_no
	]

	for i in range(labels.size()):
		var label := labels[i]

		if not label.visible:
			continue

		label.text = label.text.trim_prefix("> ")

		if i == purchase_popup_index:
			label.text = "> " + label.text
			label.modulate = Color(1.0, 0.667, 0.0, 1.0)
		else:
			label.modulate = Color(0.0, 0.918, 1.0, 1.0)


func _handle_purchase_popup_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		purchase_popup_index = 0
		_update_purchase_popup_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		if purchase_no.visible:
			purchase_popup_index = 1
			_update_purchase_popup_selection()

		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		_confirm_purchase_popup_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_cancel"):
		_close_purchase_popup()
		get_viewport().set_input_as_handled()


func _confirm_purchase_popup_selection() -> void:
	match purchase_popup_state:
		PurchasePopupState.CONFIRM_PURCHASE:
			if purchase_popup_index == 0:
				_attempt_pending_purchase()
			else:
				_close_purchase_popup()

		PurchasePopupState.ALREADY_OWNED:
			_close_purchase_popup()

		PurchasePopupState.PURCHASED:
			_close_purchase_popup()


func _attempt_pending_purchase() -> void:
	if pending_purchase_ball_id.is_empty():
		_close_purchase_popup()
		return

	var purchased: bool = SaveManager.purchase_ball(
		pending_purchase_ball_id
	)

	if not purchased:
		purchase_message.text = "NOT ENOUGH NEUROBITS"
		purchase_yes.text = "OK"
		purchase_no.hide()

		purchase_popup_state = PurchasePopupState.PURCHASED
		purchase_popup_index = 0
		_update_purchase_popup_selection()
		return

	var ball_data := BallCatalog.get_ball(
		pending_purchase_ball_id
	)

	var display_name := str(
		ball_data.get("display_name", "NEUROBALL")
	)

	purchase_message.text = (
		display_name
		+ "\n\nPURCHASED!"
	)

	purchase_yes.text = "OK"
	purchase_no.hide()

	purchase_popup_state = PurchasePopupState.PURCHASED
	purchase_popup_index = 0

	refresh_shop_labels()
	_update_purchase_popup_selection()


func _close_purchase_popup() -> void:
	purchase_popup.hide()

	purchase_popup_state = PurchasePopupState.CLOSED
	purchase_popup_index = 0
	pending_purchase_ball_id = ""

	purchase_yes.text = "YES"
	purchase_no.text = "NO"
	purchase_no.show()

	_update_selection()


# ============================================================
# MOUSE HOVER / POPUP CLICK ADDITIONS
# ============================================================

func _get_shop_viewport_mouse_position(mouse_position: Vector2) -> Variant:
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(mouse_position)

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * 1000.0
	)

	query.collision_mask = 1
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return null

	if result["collider"] != shop_screen_hitbox:
		return null

	var hit_position: Vector3 = result["position"]

	var quad := screen_quad.mesh as QuadMesh

	if quad == null:
		return null

	var local_hit: Vector3 = screen_quad.to_local(hit_position)
	var quad_size: Vector2 = quad.size

	var uv := Vector2(
		(local_hit.x / quad_size.x) + 0.5,
		0.5 - (local_hit.y / quad_size.y)
	)

	if (
		uv.x < 0.0
		or uv.x > 1.0
		or uv.y < 0.0
		or uv.y > 1.0
	):
		return null

	return Vector2(
		uv.x * screen_viewport.size.x,
		uv.y * screen_viewport.size.y
	)


func _try_hover_shop_item(mouse_position: Vector2) -> void:
	var viewport_position = _get_shop_viewport_mouse_position(
		mouse_position
	)

	if viewport_position == null:
		return

	for i in range(row_labels.size()):
		var label: Label = row_labels[i]

		var label_rect := Rect2(
			label.global_position,
			label.size
		)

		if label_rect.has_point(viewport_position):
			if selected_index != i:
				selected_index = i
				_update_selection()

			return


func _try_hover_purchase_popup(
	mouse_position: Vector2
) -> void:
	var viewport_position = _get_shop_viewport_mouse_position(
		mouse_position
	)

	if viewport_position == null:
		return

	var yes_rect := Rect2(
		purchase_yes.global_position,
		purchase_yes.size
	)

	if yes_rect.has_point(viewport_position):
		purchase_popup_index = 0
		_update_purchase_popup_selection()
		return

	if purchase_no.visible:
		var no_rect := Rect2(
			purchase_no.global_position,
			purchase_no.size
		)

		if no_rect.has_point(viewport_position):
			purchase_popup_index = 1
			_update_purchase_popup_selection()


func _try_click_purchase_popup(
	mouse_position: Vector2
) -> void:
	var viewport_position = _get_shop_viewport_mouse_position(
		mouse_position
	)

	if viewport_position == null:
		return

	var yes_rect := Rect2(
		purchase_yes.global_position,
		purchase_yes.size
	)

	if yes_rect.has_point(viewport_position):
		purchase_popup_index = 0
		_update_purchase_popup_selection()
		_confirm_purchase_popup_selection()
		return

	if purchase_no.visible:
		var no_rect := Rect2(
			purchase_no.global_position,
			purchase_no.size
		)

		if no_rect.has_point(viewport_position):
			purchase_popup_index = 1
			_update_purchase_popup_selection()
			_confirm_purchase_popup_selection()
