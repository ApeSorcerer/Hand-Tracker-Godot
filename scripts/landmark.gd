extends Node3D
class_name Landmark
var index
const LANDMARK = preload("uid://csy1l3b57iiiq")


static func create(index : int ):
	var new_lm = LANDMARK.instantiate()
	new_lm.index = index
	new_lm.set_color()
	return new_lm
func set_color():
	var mesh: MeshInstance3D = $MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf())
	mesh.set_surface_override_material(0, material)
