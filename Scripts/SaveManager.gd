extends Node

var save_path := "user://savegame.json"
var should_load_game := false  # NEW: Tracks whether to load on scene start

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return {}
	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content) if content else {}
