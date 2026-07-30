extends Node

# --- VARIABEL SAVE & LOAD (Tetap sama) ---
var score: float = 0.0
var add_score: float = 1.0
var target_score: float = 10.0
var passive_income: float = 0.0
var auto_timer_cost: float = 200.0
var auto_timer_wait_time: float = 1.0

var rebirth_cost: float = 1000.0
var rebirth_count: int = 0
var rebirth_mult: float = 1.0

const SAVE_PATH = "user://savegame.json"

func save_game():
	var save_data = {
		"score": score,
		"add_score": add_score,
		"target_score": target_score,
		"passive_income": passive_income,
		"auto_timer_cost": auto_timer_cost,
		"auto_timer_wait_time": auto_timer_wait_time,
		"rebirth_cost": rebirth_cost,
		"rebirth_count": rebirth_count,
		"rebirth_mult": rebirth_mult
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			score = data.get("score", 0.0)
			add_score = data.get("add_score", 1.0)
			target_score = data.get("target_score", 10.0)
			passive_income = data.get("passive_income", 0.0)
			auto_timer_cost = data.get("auto_timer_cost", 200.0)
			auto_timer_wait_time = data.get("auto_timer_wait_time", 1.0)
			rebirth_cost = data.get("rebirth_cost", 1000.0)
			rebirth_count = data.get("rebirth_count", 0)
			rebirth_mult = data.get("rebirth_mult", 1.0)

func reset_progress():
	score = 0.0
	add_score = 1.0
	target_score = 10.0
	passive_income = 0.0
	auto_timer_cost = 200.0
	auto_timer_wait_time = 1.0
	save_game()

# ==========================================
# --- FUNGSI POPUP GLOBAL ---
# ==========================================
# ==========================================
# --- FUNGSI POPUP GLOBAL ---
# ==========================================
# ==========================================
# --- FUNGSI POPUP GLOBAL ---
# ==========================================
# ==========================================
# --- FUNGSI POPUP GLOBAL FLEKSIBEL ---
# ==========================================
func popup(custom_text: String = "", arg2: Variant = null, arg3: float = 0.6):
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	# Deteksi otomatis: Apakah argumen ke-2 dikirim angka durasi atau Node UI?
	var fade_duration: float = 0.6
	
	if typeof(arg2) == TYPE_FLOAT or typeof(arg2) == TYPE_INT:
		fade_duration = float(arg2)
	elif typeof(arg2) == TYPE_OBJECT and arg3 is float:
		fade_duration = arg3

	# 1. Buat PanelContainer sebagai Background
	var panel = PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS

	# 2. Desain Style Background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.85)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.3)
	
	panel.add_theme_stylebox_override("panel", style)

	# 3. Buat Label Teks
	var label = Label.new()
	label.text = custom_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	panel.add_child(label)
	current_scene.add_child(panel)
	panel.show()

	# 4. Kalkulasi Ukuran & Posisi
	await get_tree().create_timer(0.01, true, false, true).timeout
	panel.reset_size()

	var viewport_size = panel.get_viewport_rect().size
	var start_x = (viewport_size.x / 2.0) - (panel.size.x / 2.0)
	var start_y = 543.0 - (panel.size.y / 2.0)

	var start_pos = Vector2(start_x, start_y)
	panel.position = start_pos
	panel.modulate.a = 1.0

	# 5. Animasi Melayang & Fade Out
	var tween = panel.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	tween.tween_property(panel, "position:y", start_pos.y - 50, fade_duration)
	tween.tween_property(panel, "modulate:a", 0.0, fade_duration)

	tween.chain().tween_callback(panel.queue_free)