extends Node3D

# Exported NodePaths to assign in the editor
@export var area_node_path: NodePath            # The Area3D node that detects player proximity
@export var desktop_ui_node_path: NodePath      # The CanvasLayer or Control for the computer desktop UI
@export var prompt_node_path: NodePath          # The Label or Control for the "Press 'F' to start the computer" prompt

# Internal state variables
var player_in_range := false        # True if player is inside the interaction area
var prompt_visible := false         # True if the prompt is currently shown

# Cached node references
var desktop_ui: Control             # Reference to the desktop UI node
var area: Area3D                   # Reference to the Area3D node
var prompt_label: Control          # Reference to the prompt UI node (Label or Control)

func _ready() -> void:
	# Retrieve node references safely from assigned NodePaths
	area = get_node_or_null(area_node_path)
	desktop_ui = get_node_or_null(desktop_ui_node_path)
	prompt_label = get_node_or_null(prompt_node_path)
	
	# Verify area node and connect signals
	if area == null:
		push_error("Area3D node not assigned or not found!")
	else:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	
	# Initialize UI visibility states
	if desktop_ui == null:
		push_error("Desktop UI node not assigned or not found!")
	else:
		desktop_ui.visible = false
	
	if prompt_label == null:
		push_error("Prompt UI node not assigned or not found!")
	else:
		prompt_label.visible = false

func _process(delta: float) -> void:
	# Listen for interact key if player is in range
	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Interact pressed. prompt_visible =", prompt_visible, ", desktop_ui.visible =", desktop_ui.visible)
		if prompt_visible:
			# First press hides prompt, shows desktop UI, and makes mouse visible
			prompt_label.visible = false
			prompt_visible = false
			if desktop_ui:
				desktop_ui.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Prompt hidden, desktop UI shown, desktop_ui.visible =", desktop_ui.visible)
		else:
			# Subsequent presses toggle the desktop UI visibility and mouse mode
			if desktop_ui:
				desktop_ui.visible = !desktop_ui.visible
				Input.set_mouse_mode(
					Input.MOUSE_MODE_VISIBLE if desktop_ui.visible else Input.MOUSE_MODE_CAPTURED
				)
			print("Toggled desktop UI visibility to:", desktop_ui.visible)

func _on_body_entered(body: Node) -> void:
	# Check if player entered interaction area
	if body.name == "Player":
		player_in_range = true
		if prompt_label:
			prompt_label.visible = true
			prompt_visible = true
		print("Player entered interaction area")

func _on_body_exited(body: Node) -> void:
	# Check if player left interaction area
	if body.name == "Player":
		player_in_range = false
		if prompt_label:
			prompt_label.visible = false
			prompt_visible = false
		if desktop_ui:
			desktop_ui.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Player left interaction area")
