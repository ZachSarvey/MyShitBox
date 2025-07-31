extends Control

@onready var fullscreen_checkbox = $CanvasLayer/FullscreenCheckBox
@onready var volume_slider = $CanvasLayer/VolumeSlider
@onready var sensitivity_slider = $CanvasLayer/SensitivitySlider

func _ready():
	print("Settings menu loaded")
	print("Fullscreen: ", SettingsManager.fullscreen)
	print("Volume: ", SettingsManager.volume)
	print("Mouse Sensitivity: ", SettingsManager.mouse_sensitivity)

	# Initialize UI values from SettingsManager singleton
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = SettingsManager.fullscreen
	if volume_slider:
		volume_slider.value = SettingsManager.volume
	if sensitivity_slider:
		sensitivity_slider.value = SettingsManager.mouse_sensitivity

func _on_FullscreenCheckBox_toggled(pressed: bool) -> void:
	SettingsManager.set_fullscreen(pressed)

func _on_VolumeSlider_value_changed(value: float) -> void:
	SettingsManager.set_volume(value)

func _on_SensitivitySlider_value_changed(value: float) -> void:
	SettingsManager.set_mouse_sensitivity(value)

func _on_Back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_SaveButton_pressed() -> void:
	print("Save button pressed")
	if volume_slider == null or sensitivity_slider == null or fullscreen_checkbox == null:
		print("Error: One or more UI elements are null!")
		return
	print("volume_slider.value:", volume_slider.value)
	SettingsManager.set_volume(volume_slider.value)
	SettingsManager.set_mouse_sensitivity(sensitivity_slider.value)
	SettingsManager.set_fullscreen(fullscreen_checkbox.button_pressed)
