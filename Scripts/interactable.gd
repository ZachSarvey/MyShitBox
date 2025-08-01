extends RigidBody3D

@export var outline_mesh: MeshInstance3D

var current_tween: Tween = null

func _ready():
	if outline_mesh:
		outline_mesh.visible = true
		_set_outline_alpha(0.0)

func highlight(enabled: bool) -> void:
	if not outline_mesh:
		return

	# Cancel any running tween before starting a new one
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
