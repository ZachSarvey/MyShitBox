extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_StartGame_pressed():
	get_tree().change_scene_to_file("res://Scenes/Garage_Scene.tscn")

func _on_LoadGame_pressed():
	SaveManager.should_load_game = true
	get_tree().change_scene_to_file("res://Scenes/Garage_Scene.tscn")

func _on_Quit_pressed():
	get_tree().quit()
