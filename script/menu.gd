extends Control

func _on_resume_button_pressed() -> void:
	get_tree().paused = false # Unpause game
	queue_free() # Hapus overlay pause, game lama langsung berlanjut!

func _on_exit_button_pressed() -> void:
	get_tree().quit()
