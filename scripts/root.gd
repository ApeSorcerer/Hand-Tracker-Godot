extends Node3D

var server : UDPServer
var json : JSON
const HAND_PARENT = preload("uid://baigd2vgk7eik")

@onready var camera_3d: Camera3D = $Camera3D

const MAX_HANDS = 1
const MOVEMENT_MULTIPLIER := Vector3(2, 2, 1)
var landmarkScenes = []
var hands : Array[Hand]
var smoothed := {}
func smooth(idx, value, alpha := 0.8): 
	if not smoothed.has(idx): 
		smoothed[idx] = value 
		smoothed[idx] = smoothed[idx].lerp(value, alpha) 
	return smoothed[idx]
func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242)
	json = JSON.new()
	for i in range(MAX_HANDS):
		var thisHand = HAND_PARENT.instantiate()
		add_child(thisHand)
		thisHand.global_position = Vector3(10, 10, 10)
		hands.append(thisHand)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("switch"):
		camera_3d.global_position.z = -camera_3d.global_position.z
		camera_3d.global_rotation.y = -180 if camera_3d.global_rotation.y==0 else 0

func _process(delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		var rawdata = packet.get_string_from_utf8()
		var error = json.parse(rawdata)
		if error == OK:
			var handsdata = json.data["hands"]
			for hand in handsdata:
				var handid = int(hand["hand_id"])
				var thisHandNode = hands[handid-1]
				var landmarks = hand["landmarks"]
				
				var wrist = landmarks[0]
				var middle = landmarks[9]
				
				var wrist_pos = Vector3(-wrist["x"], -wrist["y"], wrist["z"])
				var middle_pos = Vector3(-middle["x"], -middle["y"], middle["z"])
				
				var current_size = wrist_pos.distance_to(middle_pos)
				var target_size = 0.2
				var scale = target_size / current_size
				var index = 0
				for landmark in landmarks:
					var pos = Vector3(
						-landmark["x"],
						-landmark["y"],
						landmark["z"]
					)
					var local = (pos - wrist_pos) * scale
					smooth(index, local)
					thisHandNode.landmarkScenes[index].position = local
					index+=1
				if not thisHandNode.has_origin:
					thisHandNode.origin = wrist_pos
					thisHandNode.has_origin = true
				var ref = wrist_pos - thisHandNode.origin
				thisHandNode.global_position.z = -current_size * 5.0 * MOVEMENT_MULTIPLIER.z
				thisHandNode.global_position.x = ref.x * MOVEMENT_MULTIPLIER.x
				thisHandNode.global_position.y = ref.y * MOVEMENT_MULTIPLIER.y

			
