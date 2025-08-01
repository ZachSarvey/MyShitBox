extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 6.0
@export var gravity := 9.8
@export var mouse_sensitivity := 0.003

var pitch := 0.0
var camera: Camera3D
var interaction_ray: RayCast3D
var last_highlighted: Node3D = null

var movement_enabled := true

# Pickup system
var held_item: Node3D = null
@onready var hold_point: Node3D = $Camera3D/HoldPoint  # Ensure exists in scene

func _ready():
	camera = $Camera3D
	interaction_ray = $Camera3D/InteractionRay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if not movement_enabled:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Movement input
	var input_direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_direction += transform.basis.x

	input_direction = input_direction.normalized()
	velocity.x = input_direction.x * speed
	velocity.z = input_direction.z * speed

	move_and_slide()

	_process_interaction()

func _process_interaction():
	if not movement_enabled:
		return

	var detected_item: Node3D = null

	# Raycast to find interactable with highlight method in hierarchy
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		while collider and not collider.has_method("highlight"):
			collider = collider.get_parent()
		if collider and collider.has_method("highlight"):
			detected_item = collider

	# Highlight logic
	if detected_item != last_highlighted:
		if last_highlighted and last_highlighted.has_method("highlight"):
			last_highlighted.highlight(false)
		if detected_item:
			detected_item.highlight(true)
		last_highlighted = detected_item

	# Interaction input
	if Input.is_action_just_pressed("interact") and detected_item and detected_item.has_method("interact"):
		detected_item.interact()

	# Pickup / Drop input
	if Input.is_action_just_pressed("pickup"):
		if held_item:
			drop_held_item()
		elif detected_item and detected_item.has_method("pickup"):
			pickup_item(detected_item)
	else:
		if last_highlighted and not detected_item:
			last_highlighted.highlight(false)
			last_highlighted = null

func pickup_item(item: Node3D):
	if not is_instance_valid(item):
		return
	held_item = item

	# Freeze physics if RigidBody3D
	if held_item is RigidBody3D:
		held_item.freeze = true

	var parent = held_item.get_parent()
	if parent:
		parent.remove_child(held_item)

	hold_point.add_child(held_item)
	held_item.transform = Transform3D.IDENTITY
	held_item.position = Vector3.ZERO

func drop_held_item():
	if not is_instance_valid(held_item):
		held_item = null
		return

	if held_item is RigidBody3D:
		held_item.freeze = false

	var world = get_tree().current_scene
	hold_point.remove_child(held_item)
	world.add_child(held_item)
	held_item.global_transform = hold_point.global_transform
	held_item = null

func _input(event):
	if not movement_enabled:
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = pitch

func get_save_data() -> Dictionary:
	return {
		"position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z
		},
		"rotation": {
			"x": rotation_degrees.x,
			"y": rotation_degrees.y,
			"z": rotation_degrees.z
		}
	}

func load_from_save(data: Dictionary) -> void:
	if data.has("position"):
		var p = data["position"]
		global_position = Vector3(p["x"], p["y"], p["z"])

	if data.has("rotation"):
		var r = data["rotation"]
		rotation_degrees = Vector3(r["x"], r["y"], r["z"])

func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
