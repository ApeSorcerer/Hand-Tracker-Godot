extends Node3D
class_name Segment
const SEGMENT = preload("uid://o4q8tofjf0vj")

var handParent : Hand
var startLM : int
var endLM : int
var startPos : Vector3
var endPos : Vector3

@onready var mesh: MeshInstance3D = $MeshInstance3D
func _ready() -> void:
	mesh.mesh = mesh.mesh.duplicate()
func _process(delta: float) -> void:
	startPos = handParent.getLandmarkPosition(startLM)
	endPos = handParent.getLandmarkPosition(endLM)
	position = (endPos + startPos) * 0.5
	var v = endPos - startPos
	if v.length_squared() < 0.000001:
		return
	var dir = v.normalized()
	var scale := global_transform.basis.get_scale()
	var b := Basis().looking_at(dir, Vector3.UP)
	b = b.rotated(b.x, deg_to_rad(90)) # Y-axis capsule fix
	b = b.scaled(scale)
	global_transform.basis = b
	var length = Vector3(startPos - endPos).length()
	var capsule = mesh.mesh as CapsuleMesh
	if capsule:
		capsule.height = length * 10
		capsule.radius = 0.1
	
