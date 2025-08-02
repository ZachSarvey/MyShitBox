extends RigidBody3D
class_name WorldObject

# --- WorldObject Save/Load Properties ---
@export var object_id: String
@export var scene_path: String = "" 

# --- Interactable Properties ---
@export var outline_mesh: MeshInstance3D

var current_tween: Tween = null


# --- Core Functions ---
func _ready():
	# ADD THESE PRINT STATEMENTS
	print("WorldObject _ready() called on node: ", self.name)
	print("  - object_id is: ", object_id)
	print("  - scene_path is: ", scene_path)
	
	if outline_mesh:
		outline_mesh.visible = true
		_set_outline_alpha(0.0)
	
	if object_id == "":
		push_warning("WorldObject has no object_id! Cannot be saved/loaded.")
		return
	if scene_path == "":
		push_warning("WorldObject has no scene_path! You must manually set it in the Inspector for saving to work.")
		return
	
	WorldInventoryState.register_object(object_id, self)
	print("  - Successfully registered object: ", object_id)

# --- Interactable Methods ---
func highlight(enabled: bool) -> void:
	if not outline_mesh:
		return

	if current_tween and current_tween.is_valid():
		current_tween.kill()

	var target_alpha = 0.3 if enabled else 0.0
	current_tween = get_tree().create_tween()
	current_tween.tween_method(_set_outline_alpha, get_outline_alpha(), target_alpha, 0.15)

func _set_outline_alpha(alpha: float) -> void:
	var mat := outline_mesh.get_active_material(0)
	if mat and mat is ShaderMaterial:
		var color = mat.get_shader_parameter("outline_color")
		color.a = alpha
		mat.set_shader_parameter("outline_color", color)

func get_outline_alpha() -> float:
	var mat := outline_mesh.get_active_material(0)
	if mat and mat is ShaderMaterial:
		return mat.get_shader_parameter("outline_color").a
	return 0.0

# Dummy function for pickup compatibility
func pickup() -> void:
	pass
