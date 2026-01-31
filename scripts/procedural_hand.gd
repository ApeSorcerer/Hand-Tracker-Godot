extends Node3D
class_name Hand
var bones: Array

func _ready():
	bones = get_tree().get_nodes_in_group("bones")
	
func update_from_landmarks(landmarks: Array):
	for bone in bones:
		bone.update_from_landmarks(landmarks)
