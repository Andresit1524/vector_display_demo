extends Node2D

const REFRESH_FPS_TIME: float = 0.1

@onready var fps_label := $UILayer/UI/SettingsPanel/Margin/Content/FPSLabel

var elapsed_time: float = 0.0

func _process(delta: float) -> void:
	_refresh_fps(delta)

func _refresh_fps(delta: float) -> void:
	elapsed_time += delta

	if elapsed_time >= REFRESH_FPS_TIME:
		fps_label.text = "FPS: %d" % round(1 / delta)
		elapsed_time = 0

func _on_exit_button_pressed() -> void:
	SceneManager.change_to_scene("simulator_selector")