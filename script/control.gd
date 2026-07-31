extends Control

const PAUSE_MENU_SCENE = preload("res://scenes/menu.tscn")

# Dibungkus ke Dictionary biar rapi & pas dipanggil ke Global tinggal kirim 1 variabel!
@onready var ui: Dictionary = {
	"textlabel": $scorelabel,
	"textlabel2": $upgrade1,
	"textlabel3": $speedlabel,
	"richlabel": $RichTextLabel,
	"button": $Button,
	"upgrade_button": $remove_button,
	"speed_button": $speed_timer,
	"rebirth_button": $rebirth_button
}

@onready var infolabel = $infolabel
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
	if OS.get_name() in ["Windows", "Linux", "macOS", "Web"]:
		if event.is_action_pressed("ui_cancel"):
			if not get_tree().paused:
				open_pause_menu()

# Panggilan ke Global jadi super ringkas!
func update_score_ui():
	Global.update_score_ui(ui, auto_timer, min_auto_timer)

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
		Global.target_score_count += 1
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
			Global.speed_count += 1
			update_score_ui()
			Global.popup("Speed Upgraded!", infolabel)
		else:
			ui.speed_button.text = "Speed: MAX"
			Global.popup("Speed Max!", infolabel)
	else:
		Global.popup("Not Enough Point!", infolabel)

func _on_rebirth_button_pressed() -> void:
	if Global.score >= Global.rebirth_cost:
		Global.popup("Rebirth Success!", infolabel)
		
		# Panggil fungsi khusus rebirth dari Global
		Global.do_rebirth()
		
		# Reset timer ke default
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