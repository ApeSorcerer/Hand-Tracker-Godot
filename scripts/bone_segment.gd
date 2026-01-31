extends Node3D

@export var child_index: int = -1
@export var self_index: int = -1
@export var thickness := 0.01

@onready var mesh := $MeshInstance3D

func update_from_landmarks(landmarks: Array):
	if self_index < 0 or child_index < 0:
		return

	var a = landmarks[self_index]
	var b = landmarks[child_index]

	var dir = b - a
	var length = dir.length()
	if length < 0.0001:
		return

	# Position
	global_position = a

	# Orientation (Godot forward = -Z by default)
	look_at(b, Vector3.UP)

	# Scale mesh to match length
	mesh.scale = Vector3(thickness, thickness, length * 0.5)
	mesh.position = Vector3(0, 0, -length * 0.5)
