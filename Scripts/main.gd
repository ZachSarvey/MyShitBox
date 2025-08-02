extends Node3D

@onready var pause_menu = $PauseMenu
@onready var player = $Player

func _ready():
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if SaveManager.should_load_game:
		load_game()
		SaveManager.should_load_game = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	if event.is_action_pressed("save_game"):
		save_game()
	if event.is_action_pressed("load_game"):
		load_game()

func toggle_pause():
	var is_paused = get_tree().paused
	get_tree().paused = !is_paused
	pause_menu.visible = !is_paused

	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func save_game() -> void:
	await get_tree().physics_frame  # wait for physics frame to finish
	var save_data = {}

	save_data["player"] = player.get_save_data()
	save_data["world"] = WorldInventoryState.get_save_data()

	SaveManager.save_game(save_data)


func load_game():
	var save_data = SaveManager.load_game()

	if save_data.has("player"):
		player.load_from_save(save_data["player"])

	if save_data.has("world"):
		WorldInventoryState.load_from_save(save_data["world"])
