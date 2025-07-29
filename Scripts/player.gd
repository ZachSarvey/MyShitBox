extends CharacterBody3D
#sensitivity and movement speed tuning
var speed := 5.0
var mouse_sensitivity := 0.002
#store the look angle
var pitch := 0.0
#reference to the camera (assignment handled in _ready)
var camera: Camera3D

func _ready():
	#Grab camerea3D child
	camera = $Camera3D
	#hide mouse + capture
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
		
	# Left/right movement
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity = direction * speed

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		# Horizontal look (rotate whole player)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertical look (rotate camera only)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-89), deg_to_rad(89))
		camera.rotation.x = pitch
