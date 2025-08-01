extends Node3D

@export var area_node_path: NodePath
@export var desktop_ui_node_path: NodePath
@export var prompt_node_path: NodePath
@export var player_node_path: NodePath

var player_in_range := false
var prompt_visible := false
var logged_in := false
var pc_on := false

var desktop_ui: Control
var area: Area3D
var prompt_label: Control
var player: Node

# Login UI nodes
var login_panel: Control
var username_input: LineEdit
var password_input: LineEdit
var login_button: Button
var error_label: Label
var exit_button_login: Button

# Desktop app UI
var desktop: Control
var internet_button: Button
var internet_app: Control
var exit_button_desktop: Button

func _ready() -> void:
	area = get_node_or_null(area_node_path)
	desktop_ui = get_node_or_null(desktop_ui_node_path)
	prompt_label = get_node_or_null(prompt_node_path)
	player = get_node_or_null(player_node_path)

	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	else:
		push_error("Area3D node not assigned!")

	if desktop_ui:
		desktop_ui.visible = false
		desktop_ui.mouse_filter = Control.MOUSE_FILTER_STOP

		# Get login UI
		login_panel = desktop_ui.get_node("LoginPanel")
		username_input = login_panel.get_node("UsernameInput")
		password_input = login_panel.get_node("PasswordInput")
		login_button = login_panel.get_node("LoginButton")
		error_label = login_panel.get_node("ErrorLabel")
		error_label.visible = false
		
		# Get Exit button under login panel (optional)
		exit_button_login = login_panel.get_node_or_null("ExitButton")
		
		login_button.pressed.connect(_on_login_pressed)
		if exit_button_login:
			exit_button_login.pressed.connect(_on_exit_button_pressed)
		else:
			push_error("ExitButton not found under LoginPanel!")

		# Get desktop and apps
		desktop = desktop_ui.get_node("Desktop")
		internet_button = desktop.get_node("InternetButton")
		internet_app = desktop_ui.get_node("InternetApp")
		
		# Get Exit button under desktop UI (optional)
		exit_button_desktop = desktop.get_node_or_null("ExitButton")
		
		desktop.visible = false
		internet_app.visible = false
		internet_button.pressed.connect(_on_internet_button_pressed)
		if exit_button_desktop:
			exit_button_desktop.pressed.connect(_on_exit_button_pressed)
		else:
			push_error("ExitButton not found under Desktop!")

	else:
		push_error("Desktop UI not assigned!")

	if prompt_label:
		prompt_label.visible = false
	else:
		push_error("Prompt label not assigned!")

	if player == null:
		push_error("Player node not assigned!")

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		if prompt_visible:
			prompt_label.visible = false
			prompt_visible = false
			if desktop_ui:
				desktop_ui.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				desktop_ui.mouse_filter = Control.MOUSE_FILTER_STOP

				if not logged_in:
					login_panel.visible = true
					error_label.visible = false
					username_input.text = ""
					password_input.text = ""
					desktop.visible = false
				else:
					login_panel.visible = false
					desktop.visible = true

			if player:
				player.set_movement_enabled(false)
		else:
			if logged_in and desktop_ui:
				desktop_ui.visible = !desktop_ui.visible
				if desktop_ui.visible:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					desktop_ui.mouse_filter = Control.MOUSE_FILTER_STOP
					if player:
						player.set_movement_enabled(false)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					desktop_ui.mouse_filter = Control.MOUSE_FILTER_STOP
					if player:
						player.set_movement_enabled(true)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true
			prompt_visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
			prompt_visible = false
		if desktop_ui:
			desktop_ui.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if player:
			player.set_movement_enabled(true)

func _on_login_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()

	if username == "user" and password == "pass":
		logged_in = true
		error_label.visible = false
		login_panel.visible = false
		desktop.visible = true
		print("Login successful")
	else:
		error_label.text = "Invalid username or password."
		error_label.visible = true
		print("Login failed for user:", username)

func _on_internet_button_pressed() -> void:
	if internet_app:
		internet_app.visible = true

func _on_exit_button_pressed() -> void:
	if desktop_ui:
		desktop_ui.visible = false
	if player:
		player.set_movement_enabled(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
