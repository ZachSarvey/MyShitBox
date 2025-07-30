extends CharacterBody3D

@export var speed := 5.0
@export var jump_velocity := 6.0
@export var gravity := 9.8
@export var mouse_sensitivity := 0.003

var pitch := 0.0
var camera: Camera3D
var interaction_ray: RayCast3D
var last_highlighted = null

func _ready():
	camera = $Camera3D
	interaction_ray = $Camera3D/InteractionRay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Handle movement
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
	var horizontal_velocity = input_direction * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Apply movement
	move_and_slide()

	# Process interaction and highlight
	_process_interaction()

func _process_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()

		# Climb up the node tree until a node with 'highlight' method is found
		while collider and not collider.has_method("highlight"):
			collider = collider.get_parent()

		if collider:
			if collider != last_highlighted:
				print("Hit interactable:", collider.name)
				if last_highlighted and last_highlighted.has_method("highlight"):
					last_highlighted.highlight(false)

				collider.highlight(true)
				last_highlighted = collider

			if Input.is_action_just_pressed("interact") and collider.has_method("interact"):
				print("Interacting with:", collider.name)
				collider.interact()
	else:
		if last_highlighted and last_highlighted.has_method("highlight"):
			last_highlighted.highlight(false)
		last_highlighted = null

func _input(event):
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
