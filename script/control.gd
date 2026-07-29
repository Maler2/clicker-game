extends Control

const PAUSE_MENU_SCENE = preload("res://scenes/menu.tscn")

@onready var textlabel = $scorelabel
@onready var textlabel2 = $upgrade1
@onready var textlabel3 = $speedlabel
@onready var richlabel = $RichTextLabel
@onready var infolabel = $infolabel
@onready var button = $Button
@onready var upgrade_button = $remove_button
@onready var speed_button = $speed_timer
@onready var rebirth_button = $rebirth_button
@onready var sfx = $audioplayer
@onready var auto_timer = $Timer

var score: float = 0.0
var add_score: int = 1
var remove_score: float = 10
var passive_income: int = 0
var target_score: float = 10.0
var auto_timer_cost: float = 200.0
var min_auto_timer: float = 0.1
var rebirth_cost: float = 1000.0
var rebirth_count = 0
var rebirth_mult: float = 1.0
var info_tween: Tween

var sfx_list: Dictionary = {
	"add": preload("res://sound/sfx/add.wav"),
	"remove": preload("res://sound/sfx/remove.wav")
}

func _ready():
	auto_timer.timeout.connect(add_score_auto)
	update_score_ui()
	
	# Sembunyikan infolabel master agar tidak mengganggu UI
	if infolabel:
		infolabel.hide()
		
	print("start up")

func update_score_ui():
	button.text = "+" + str(snapped(add_score * rebirth_mult, 0.1))
	upgrade_button.text = "Buy: " + str(snapped(target_score, 0.1))
	speed_button.text = "Speed: " + str(snapped(auto_timer_cost, 0.1))
	rebirth_button.text = "Rebirth: " + str(snapped(rebirth_cost, 1))
	
	if auto_timer.wait_time <= min_auto_timer:
		speed_button.text = "Speed: MAX"
	
	textlabel.text = "Score: " + str(snapped(score, 1))
	textlabel2.text = "Upgrade 1: " + str(snapped(target_score, 0.1))
	textlabel3.text = "Upgrade 2: " + str(snapped(auto_timer_cost, 0.1)) + " " + str(snapped(auto_timer.wait_time, 0.1)) + "s"
	richlabel.text = "click per score %d passive %d\nSpeed %.1fs\nRebirth %.1f" % [add_score, passive_income, auto_timer.wait_time, rebirth_mult]

func add_score_auto():
	if passive_income > 0:
		play_sfx("remove", -10.0)
		score += passive_income
		update_score_ui()
		print("passive +" + str(passive_income) + " (" + str(score) + ")")

func _on_button_pressed():
	play_sfx("add")
	var gained = add_score * rebirth_mult
	score += gained
	update_score_ui()
	popup("+" + str(snapped(gained, 0.1)))
	print("add +" + str(gained) + " (" + str(score) + ")")

func _on_remove_button_pressed() -> void:
	if score >= target_score:
		remove_score = target_score
		target_score *= 1.25
		play_sfx("remove")
		score -= remove_score
		passive_income += 1
		add_score += 1
		update_score_ui()
		popup("Upgraded!")
	else:
		popup("Not Enough Point!")

func _on_speed_timer_pressed() -> void:
	if score >= auto_timer_cost:
		if auto_timer.wait_time > min_auto_timer:
			play_sfx("remove")
			score -= auto_timer_cost
			auto_timer.wait_time *= 0.9
			auto_timer.start()
			auto_timer_cost *= 1.5
			update_score_ui()
			popup("Speed Upgraded!")
		elif auto_timer.wait_time <= min_auto_timer:
			speed_button.text = "Speed: MAX"
			popup("Speed Max!")
	else:
		popup("Not Enough Point!")

# --- FUNGSI POPUP AMAN DAN TERUJI ---
func popup(custom_text: String = ""):
	if not infolabel:
		return
		
	var popup_clone = infolabel.duplicate()
	add_child(popup_clone)
	
	# Cari node Label (bisa berupa infolabel itu sendiri atau child pertamanya)
	var label_node: Label = null
	if popup_clone is Label:
		label_node = popup_clone as Label
	elif popup_clone.get_child_count() > 0 and popup_clone.get_child(0) is Label:
		label_node = popup_clone.get_child(0) as Label

	# Set teks
	if label_node:
		label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if custom_text != "":
			label_node.text = custom_text
		else:
			label_node.text = "+" + str(add_score)

		# Hitung ukuran font & text padding tanpa karakter tersembunyi
		var font = label_node.get_theme_font("font")
		var font_size = label_node.get_theme_font_size("font_size")
		
		if font:
			var real_text_size = font.get_string_size(
				label_node.text, 
				HORIZONTAL_ALIGNMENT_CENTER, 
				-1.0, 
				font_size
			)
			var padding = Vector2(30, 14)
			var target_size = real_text_size + padding
			
			popup_clone.custom_minimum_size = target_size
			popup_clone.size = target_size
			label_node.size = target_size

	popup_clone.show()
	await get_tree().process_frame # Tunggu frame agar ukuran UI ter-render
	
	# --- POSISI RATA TENGAH (X) & Y = 543 ---
	var screen_width = get_viewport_rect().size.x
	var start_x = (screen_width / 2.0) - (popup_clone.size.x / 2.0)
	var start_y = 543.0 - (popup_clone.size.y / 2.0)
	
	var start_pos = Vector2(start_x, start_y)
	popup_clone.position = start_pos
	popup_clone.modulate.a = 1.0
	
	# --- ANIMASI MELAYANG NAIK & FADE OUT ---
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(popup_clone, "position:y", start_pos.y - 50, 0.6)
	tween.tween_property(popup_clone, "modulate:a", 0.0, 0.6)
	
	tween.chain().tween_callback(popup_clone.queue_free)

func open_pause_menu():
	get_tree().paused = true
	var pause_instance = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_instance)

func _on_pausebutton_pressed() -> void:
	open_pause_menu()
	
func play_sfx(sound: String, volume: float = 0.0) -> void:
	if sfx_list.has(sound):
		sfx.stream = sfx_list[sound]
		sfx.volume_db = volume
		sfx.play()

func _on_rebirth_button_pressed() -> void:
	if score >= rebirth_cost:
		popup("Rebirth Success!")
		rebirth_count += 1
		rebirth_mult += 0.5
		rebirth_cost *= 2.5
		score = 0
		add_score = 1
		passive_income = 0
		auto_timer_cost = 200.0
		target_score = 10.0
		auto_timer.wait_time = 1.0
		update_score_ui()
	else:
		popup("Not Enough Point!")
