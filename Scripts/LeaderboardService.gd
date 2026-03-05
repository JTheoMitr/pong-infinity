extends Node

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
func set_display_name_best_effort(name: String) -> void:
	_set_display_name_async(name.strip_edges())

func _set_display_name_async(name: String) -> void:
	if name == "":
		return
	if not await _ensure_session():
		return

	var upd: Variant = await _client.update_account_async(_session, name, null, null, null, null, null)
	if upd == null or upd.is_exception():
		last_error = "Name update failed"

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

	# Signature (your SDK): (session, leaderboard_id, owner_ids:Array, limit:int, expiry:int, cursor:String)
	var owner_ids: Array = []
	var expiry: int = 0          # 0 = no expiry filter
	var cursor: String = ""      # empty = first page

	var r: Variant = await _client.list_leaderboard_records_async(_session, LEADERBOARD_ID, owner_ids, TOP_N, expiry, cursor)
	if r == null or r.is_exception():
		last_error = "Fetch failed"
		if callback.is_valid():
			callback.call(cached_top, false, last_error)
		return

	cached_top = r.records
	if callback.is_valid():
		callback.call(cached_top, true, "")
