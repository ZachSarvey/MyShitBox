extends Node

var volume := 1.0
var mouse_sensitivity := 1.0
var fullscreen := false

func _ready():
	print("[SettingsManager] Ready")
	# Just apply current settings (no load/save for now)
	apply_settings()

func apply_settings():
	set_volume(volume)
	set_fullscreen(fullscreen)
	# mouse_sensitivity is usually used in gameplay code

func set_volume(value: float) -> void:
	volume = clamp(value, 0.0, 1.0)
	var db = linear_to_db(volume)
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, db)
	print("[SettingsManager] Volume set to ", volume, " (", db, " dB)")

func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = max(value, 0.01)  # prevent zero or negative
	print("[SettingsManager] Mouse sensitivity set to ", mouse_sensitivity)

func set_fullscreen(state: bool) -> void:
	fullscreen = state
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)
	print("[SettingsManager] Fullscreen set to ", fullscreen)
