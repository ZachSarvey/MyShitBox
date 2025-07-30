extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SettingsManager.apply_settings()  # <-- Add this line to apply saved settings on menu start

func _on_StartGame_pressed():
	get_tree().change_scene_to_file("res://Scenes/Garage_Scene.tscn")

func _on_LoadGame_pressed():
	SaveManager.should_load_game = true
	get_tree().change_scene_to_file("res://Scenes/Garage_Scene.tscn")

func _on_Settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/SettingsMenu.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _audio_ready():
	$AudioStreamPlayer.play()

func _check_settings():
	if SettingsManager == null:
		print("SettingsManager is NULL in main menu!")
	else:
		print("SettingsManager is available! Volume:", SettingsManager.volume)
