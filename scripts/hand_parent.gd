extends Node3D
class_name Hand
var active : bool
var landmarkScenes = []
var segmentScenes = []
const SEGMENT = preload("uid://o4q8tofjf0vj")
var origin := Vector3.ZERO
var has_origin := false
var connections = [
	Vector2i(0,1),
	Vector2i(1,2),
	Vector2i(2,3),
	Vector2i(3,4),
	Vector2i(0,5),
	Vector2i(5,6),
	Vector2i(6,7),
	Vector2i(7,8),
	Vector2i(5,9),
	Vector2i(9,10),
	Vector2i(10,11),
	Vector2i(11,12),
	Vector2i(9,13),
	Vector2i(13,14),
	Vector2i(14,15),
	Vector2i(15,16),
	Vector2i(13,17),
	Vector2i(17,18),
	Vector2i(18,19),
	Vector2i(19,20),
	Vector2i(0,17),
]
func _ready() -> void:
	for i in range(21):
		var lm = Landmark.create(i)
		add_child(lm)
		landmarkScenes.append(lm)
	for c in connections:
		var seg : Segment = SEGMENT.instantiate()
		seg.startLM = c.x
		seg.endLM = c.y
		seg.handParent = self
		add_child(seg)
		segmentScenes.append(seg)
func getLandmarkPosition(index) -> Vector3:
	return landmarkScenes[index].position
