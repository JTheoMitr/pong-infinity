extends Node

@onready var _http: HTTPRequest = HTTPRequest.new()
# ===== Local dev settings (change HOST later to Hetzner IP) =====
const SERVER_KEY: String = "defaultkey"
const HOST: String = "127.0.0.1"
const PORT: int = 7350
const SCHEME: String = "http" # use "https" when you put it behind TLS later

const LEADERBOARD_ID: String = "global_scores"
const TOP_N: int = 10

var _client: NakamaClient
var _session: NakamaSession

# cached for offline fallback
var cached_top: Array = []
var last_error: String = ""

func _ready() -> void:
	_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)
	add_child(_http)

func _ensure_session() -> bool:
	if _session != null and not _session.is_expired():
		return true

	var device_id: String = OS.get_unique_id()
	var res: Variant = await _client.authenticate_device_async(device_id, null, true)

	if res == null or res.is_exception():
		last_error = "Auth failed"
		return false

	_session = res
	return true

# Optional: set name (best effort, never blocks gameplay)
func set_display_name_best_effort(name: String) -> bool:
	return await _set_display_name_async(name.strip_edges())

func _set_display_name_async(name: String) -> bool:
	if name == "":
		return false
	if not await _ensure_session():
		return false

	var upd: Variant = await _client.update_account_async(_session, name, null, null, null, null, null)
	if upd == null or upd.is_exception():
		last_error = "Name update failed"
		return false

	return true
# Non-blocking submit (won't break game if it fails)
func submit_score_best_effort(score: int) -> void:
	_submit_score_async(score)

func _submit_score_async(score: int) -> void:
	if not await _ensure_session():
		return

	var w: Variant = await _client.write_leaderboard_record_async(_session, LEADERBOARD_ID, score, 0, {})
	if w == null or w.is_exception():
		last_error = "Submit failed"

# Fetch top N and return via callback: callback(records:Array, ok:bool, err:String)
func fetch_top_best_effort(callback: Callable) -> void:
	_fetch_top_async(callback)

func _fetch_top_async(callback: Callable) -> void:
	if not await _ensure_session():
		if callback.is_valid():
			callback.call(cached_top, false, last_error)
		return

	var url := "%s://%s:%d/v2/leaderboard/%s?limit=%d" % [
		SCHEME,
		HOST,
		PORT,
		LEADERBOARD_ID.uri_encode(),
		TOP_N
	]

	var headers := PackedStringArray([
		"Authorization: Bearer %s" % _session.token,
		"Accept: application/json"
	])

	var err := _http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		last_error = "Fetch request failed"
		if callback.is_valid():
			callback.call(cached_top, false, last_error)
		return

	var result: Array = await _http.request_completed
	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3] as PackedByteArray

	if response_code != 200:
		last_error = "Fetch failed (%d)" % response_code
		if callback.is_valid():
			callback.call(cached_top, false, last_error)
		return

	var json_text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(json_text)

	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("records"):
		last_error = "Invalid leaderboard response"
		if callback.is_valid():
			callback.call(cached_top, false, last_error)
		return

	cached_top = parsed["records"]
	if callback.is_valid():
		callback.call(cached_top, true, "")
		
		
func _sanitize_name(raw_name: String) -> String:
	var base := raw_name.to_lower().replace(" ", "_").strip_edges()
	var cleaned := ""

	for i in range(base.length()):
		var ch := base[i]
		var code := ch.unicode_at(0)
		var is_num := code >= 48 and code <= 57
		var is_low := code >= 97 and code <= 122
		if is_num or is_low or ch == "_":
			cleaned += ch

	return cleaned


func submit_score_with_name_best_effort(player_name: String, score: int) -> void:
	_submit_score_with_name_async(player_name.strip_edges(), score)

func _submit_score_with_name_async(player_name: String, score: int) -> void:
	var clean_name := _sanitize_name(player_name)
	if clean_name == "":
		clean_name = "player"

	var guest_id := "%s_%d_%d" % [
		clean_name,
		Time.get_unix_time_from_system(),
		randi_range(1000, 9999)
	]

	# 1) Create fresh guest account
	var auth_res: Variant = await _client.authenticate_device_async(guest_id, null, true)
	if auth_res == null or auth_res.is_exception():
		last_error = "Auth failed"
		return

	_session = auth_res

	# 2) Set entered username
	var final_name := clean_name
	var updated := false

	for i in range(5):
		var upd: Variant = await _client.update_account_async(_session, final_name, null, null, null, null, null)
		if upd != null and not upd.is_exception():
			updated = true
			break

		final_name = "%s_%d" % [clean_name, randi_range(1000, 9999)]

	if not updated:
		last_error = "Name update failed"
		return

	# 3) RE-AUTHENTICATE so session token has the updated username
	var refreshed: Variant = await _client.authenticate_device_async(guest_id, null, true)
	if refreshed == null or refreshed.is_exception():
		last_error = "Re-auth failed"
		return

	_session = refreshed

	# 4) Submit score using refreshed session
	var w: Variant = await _client.write_leaderboard_record_async(_session, LEADERBOARD_ID, score, 0, {})
	if w == null or w.is_exception():
		last_error = "Submit failed"
