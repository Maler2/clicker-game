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
@onready var pause_button = $pausebutton
@onready var sfx = $audioplayer
@onready var auto_timer = $Timer

var min_auto_timer: float = 0.1
var menu_instance = null

var sfx_list: Dictionary = {
	"add": preload("res://sound/sfx/add.wav"),
	"remove": preload("res://sound/sfx/remove.wav")
}

func _ready():
	# process_mode = Node.PROCESS_MODE_ALWAYS
	var current_os = OS.get_name()
	if current_os in ["Windows", "Linux", "macOS", "Web"]:
		pause_button.hide()
	else:
		pause_button.show()


	Global.load_game()
	auto_timer.wait_time = Global.auto_timer_wait_time
	auto_timer.timeout.connect(add_score_auto)
	auto_timer.start()
	
	update_score_ui()
	
	if infolabel:
		infolabel.hide()
		
	print("start up")

func _unhandled_input(event):
	# Khusus PC/Komputer: Cek kalau OS-nya Windows/Linux/macOS/Web
	if OS.get_name() in ["Windows", "Linux", "macOS", "Web"]:
		# Cek kalau pemain menekan tombol keyboard/action di Input Map (misal: "toggle_pause" atau "ui_cancel")
		if event.is_action_pressed("ui_cancel"):
			# Cek biar gak buka menu pause berlapis-lapis kalau game udah paused
			if not get_tree().paused:
				open_pause_menu()

func update_score_ui():
	button.text = "+" + str(snapped(Global.add_score * Global.rebirth_mult, 0.1))
	upgrade_button.text = "Buy: " + str(snapped(Global.target_score, 0.1))
	speed_button.text = "Speed: " + str(snapped(Global.auto_timer_cost, 0.1))
	rebirth_button.text = "Rebirth: " + str(snapped(Global.rebirth_cost, 1))
	
	if auto_timer.wait_time <= min_auto_timer:
		speed_button.text = "Speed: MAX"
	
	textlabel.text = ": " + str(snapped(Global.score, 1))
	textlabel2.text = "Upgrade 1: " + str(snapped(Global.target_score, 0.1))
	textlabel3.text = "Upgrade 2: " + str(snapped(Global.auto_timer_cost, 0.1)) + " " + str(snapped(auto_timer.wait_time, 0.1)) + "s"
	richlabel.text = "click per score %.1f passive %.1f\nSpeed %.1fs\nRebirth %.1f" % [Global.add_score, Global.passive_income, auto_timer.wait_time, Global.rebirth_mult]

func add_score_auto():
	if Global.passive_income > 0:
		play_sfx("remove", -10.0)
		Global.score += Global.passive_income
		update_score_ui()

func _on_button_pressed():
	play_sfx("add")
	var gained = Global.add_score * Global.rebirth_mult
	Global.score += gained
	
	update_score_ui()
	Global.popup("+" + str(snapped(gained, 0.1)), infolabel)

func _on_remove_button_pressed() -> void:
	if Global.score >= Global.target_score:
		var remove_cost = Global.target_score
		Global.target_score *= 1.25
		play_sfx("remove")
		Global.score -= remove_cost
		Global.passive_income += 1
		Global.add_score += 1
		update_score_ui()
		Global.popup("Upgraded!", infolabel)
	else:
		Global.popup("Not Enough Point!", infolabel)

func _on_speed_timer_pressed() -> void:
	if Global.score >= Global.auto_timer_cost:
		if auto_timer.wait_time > min_auto_timer:
			play_sfx("remove")
			Global.score -= Global.auto_timer_cost
			auto_timer.wait_time *= 0.9
			Global.auto_timer_wait_time = auto_timer.wait_time
			auto_timer.start()
			Global.auto_timer_cost *= 1.5
			update_score_ui()
			Global.popup("Speed Upgraded!", infolabel)
		else:
			speed_button.text = "Speed: MAX"
			Global.popup("Speed Max!", infolabel)
	else:
		Global.popup("Not Enough Point!", infolabel)

func _on_rebirth_button_pressed() -> void:
	if Global.score >= Global.rebirth_cost:
		Global.popup("Rebirth Success!", infolabel)
		Global.rebirth_count += 1
		Global.rebirth_mult += 0.5
		Global.rebirth_cost *= 2.5
		
		Global.reset_progress()
		auto_timer.wait_time = Global.auto_timer_wait_time
		auto_timer.start()
		
		update_score_ui()
	else:
		Global.popup("Not Enough Point!", infolabel)

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