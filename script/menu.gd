extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if OS.get_name() in ["Windows", "Linux", "macOS", "Web"]:
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_on_resume_button_pressed()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_save_button_pressed() -> void:
	Global.save_game()
	Global.popup("Saved!")

func _on_option_button_pressed() -> void:
	var option_scene = load("res://scenes/option.tscn").instantiate()
	
	# Buat CanvasLayer darurat agar Option dirender di paling depan
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Paksa layer ke paling atas
	canvas_layer.add_child(option_scene)
	
	add_child(canvas_layer)
	
	# Sembunyikan elemen visual menu utama biar tidak bertumpuk
	visible = false

func _on_exit_button_pressed() -> void:
	Global.popup("Quitting...", 1.0)
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().quit()