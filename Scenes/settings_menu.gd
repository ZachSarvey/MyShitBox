extends Control

@onready var fullscreen_checkbox = $FullscreenCheckBox
@onready var volume_slider = $VolumeSlider
@onready var sensitivity_slider = $SensitivitySlider

func _ready():
	# Initialize UI with saved settings or defaults
	load_settings()

func _on_FullscreenCheckBox_toggled(pressed):
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_VolumeSlider_value_changed(value):
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, value)

func _on_SensitivitySlider_value_changed(value):
	SettingsManager.mouse_sensitivity = value

func load_settings():
	var settings = SettingsManager.load_settings()
	
	if settings.has("fullscreen"):
		fullscreen_checkbox.pressed = settings["fullscreen"]
		_on_FullscreenCheckBox_toggled(settings["fullscreen"])
	
	if settings.has("volume"):
		volume_slider.value = settings["volume"]
		_on_VolumeSlider_value_changed(settings["volume"])
	
	if settings.has("sensitivity"):
		sensitivity_slider.value = settings["sensitivity"]
		_on_SensitivitySlider_value_changed(settings["sensitivity"])

func _on_SaveButton_pressed():
	var settings = {
		"fullscreen": fullscreen_checkbox.pressed,
		"volume": volume_slider.value,
		"sensitivity": sensitivity_slider.value
	}
	SettingsManager.save_settings(settings)
