extends CanvasLayer	

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer.process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer.process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer/ResumeButton.process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer/VBoxContainer/QuitButton.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_pressed():
	get_tree().paused = false
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_quit_pressed():
	get_tree().quit()
