extends Node
class_name WorldInventoryBase # The name has been changed here to avoid the conflict.

var tracked_objects := {}

func register_object(id: String, node: Node3D) -> void:
	tracked_objects[id] = node

func unregister_object(id: String) -> void:
	tracked_objects.erase(id)

func vector3_to_dict(v: Vector3) -> Dictionary:
	return {"x": v.x, "y": v.y, "z": v.z}

func dict_to_vector3(d: Dictionary) -> Vector3:
	return Vector3(d.get("x", 0.0), d.get("y", 0.0), d.get("z", 0.0))

func transform_to_dict(xform: Transform3D) -> Dictionary:
	return {
		"origin": vector3_to_dict(xform.origin),
		"basis_x": vector3_to_dict(xform.basis.x),
		"basis_y": vector3_to_dict(xform.basis.y),
		"basis_z": vector3_to_dict(xform.basis.z)
	}

func dict_to_transform(data: Dictionary) -> Transform3D:
	var basis := Basis(
		dict_to_vector3(data.get("basis_x", {})),
		dict_to_vector3(data.get("basis_y", {})),
		dict_to_vector3(data.get("basis_z", {}))
	)
	var origin := dict_to_vector3(data.get("origin", {}))
	return Transform3D(basis, origin)

func get_save_data() -> Dictionary:
	var data := {}
	for id in tracked_objects:
		var obj = tracked_objects[id]
		if obj.has_method("get"):
			var scene_path = obj.get("scene_path")
			if scene_path == "" or scene_path == null:
				push_warning("WorldInventory: Object '" + id + "' missing scene_path during save! Skipping.")
				continue
			data[id] = {
				"scene": scene_path,
				"transform": transform_to_dict(obj.global_transform),
			}
	return data

func load_from_save(data: Dictionary) -> void:
	for id in tracked_objects:
		var obj = tracked_objects[id]
		if obj.is_queued_for_deletion():
			continue
		obj.queue_free()
	
	tracked_objects.clear()

	for id in data:
		var entry = data[id]
		var scene_path = entry.get("scene", "")

		if typeof(scene_path) != TYPE_STRING or scene_path.strip_edges() == "":
			push_error("Invalid or missing scene path for object ID: " + id)
			continue

		var transform_data = entry.get("transform", {})
		var transform = dict_to_transform(transform_data)
		
		var scene = ResourceLoader.load(scene_path)
		
		if scene == null:
			push_error("Failed to load scene at path: " + scene_path)
			continue
		
		var inst = scene.instantiate()

		if inst == null:
			push_error("Failed to instantiate scene for path: " + scene_path)
			continue

		get_tree().current_scene.add_child(inst)

		if inst is RigidBody3D:
			inst.set("freeze", true)
			inst.global_transform = transform
			inst.call_deferred("set", "freeze", false)
			inst.call_deferred("set", "sleeping", false)
		elif inst is Node3D:
			inst.global_transform = transform
		
		register_object(id, inst)
