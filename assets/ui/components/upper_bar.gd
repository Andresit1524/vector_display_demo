extends ColorRect

func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("start_menu")