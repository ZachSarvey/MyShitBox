extends Node

var settings_path := "user://settings.json"
var mouse_sensitivity := 1.0

func save_settings(data: Dictionary):
	var file = FileAccess.open(settings_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_settings() -> Dictionary:
	if not FileAccess.file_exists(settings_path):
		return {}
	var file = FileAccess.open(settings_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content) if content else {}
