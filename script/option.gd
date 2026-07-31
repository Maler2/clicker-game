extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		go_back_to_menu()

func _on_back_button_pressed() -> void:
	go_back_to_menu()

func go_back_to_menu() -> void:
	# Parent dari Option adalah CanvasLayer, dan Parent dari CanvasLayer adalah menu.tscn
	var canvas_layer = get_parent()
	if canvas_layer:
		var menu_node = canvas_layer.get_parent()
		if menu_node:
			menu_node.visible = true # Tampilkan menu utama lagi
		
		canvas_layer.queue_free() # Hapus CanvasLayer beserta Option di dalamnya
	else:
		queue_free()

func _on_volume_button_pressed() -> void:
	print("Tombol Volume diklik")

func _on_other_button_pressed() -> void:
	print("Tombol Other diklik")

func _on_clear_button_pressed() -> void:
	# 1. Reset progress data di Global
	Global.reset_progress()
	Global.save_game() # Opsional: Simpan state reset ke file
	
	# 2. Tampilkan notifikasi
	Global.popup("Save Reset!")
	
	# 3. Cari Scene Game Utama (control.gd) dan perbarui UI-nya langsung
	var main_game = get_tree().root.get_node_or_null("Control") # Sesuaikan "Control" dengan nama Root Node scene utama kamu
	if main_game and main_game.has_method("update_score_ui"):
		main_game.update_score_ui()