extends Control

func _ready() -> void:
	pass

func _on_resume_button_pressed() -> void:
	get_tree().paused = false # Unpause game
	queue_free() # Hapus overlay pause menu

func _on_save_button_pressed() -> void:
	Global.save_game()
	Global.popup("Saved!")

func _on_clear_button_pressed() -> void:
	Global.reset_progress()
	Global.popup("Reset Progress!")
	
	# CARA UPDATE UI GAME DI BELAKANG MENU:
	# Cari node Control/Main UI yang ada di scene utama lalu suruh update UI-nya
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("update_score_ui"):
		current_scene.update_score_ui()

func _on_exit_button_pressed() -> void:
	Global.popup("Quitting...", 1.0)
	
	# PENTING: Timer harus mengabaikan status PAUSE agar fungsi exit tidak freeze!
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().quit()