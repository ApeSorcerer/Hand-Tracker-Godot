extends Node3D

var server : UDPServer
var json : JSON
const HAND_PARENT = preload("uid://baigd2vgk7eik")

#Config
const MAX_HANDS = 1 #should be same as python script
const MOVEMENT_MULTIPLIER := Vector3(2, 2, 1)
var TARGET_SIZE = 0.2

var landmarkScenes = []
var hands : Array[Hand]
var smoothed := {}

func smooth(idx, value, alpha := 0.6): # Lower alpha = smoother
	if not smoothed.has(idx):
		smoothed[idx] = value
	else:
		smoothed[idx] = smoothed[idx].lerp(value, alpha)
	return smoothed[idx]
func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242) #must be the same as python script port
	json = JSON.new()
	for i in range(MAX_HANDS):
		var thisHand = HAND_PARENT.instantiate()
		add_child(thisHand)
		thisHand.global_position = Vector3(10, 10, 10) #arbitrary
		hands.append(thisHand)

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
				

				var indexf = landmarks[5] #used for gauging distance
				var pinkie = landmarks[17]
				var indexf_pos = Vector3(-indexf["x"], -indexf["y"], indexf["z"])
				var pinkie_pos = Vector3(-pinkie["x"], -pinkie["y"], pinkie["z"])
				
				var wrist = landmarks[0]
				var wrist_pos = Vector3(-wrist["x"], -wrist["y"], wrist["z"])
				
				var current_size = indexf_pos.distance_to(pinkie_pos)
				var scale = TARGET_SIZE / current_size
				var index = 0
				for landmark in landmarks:
					var pos = Vector3(
						-landmark["x"],
						-landmark["y"],
						landmark["z"]
					)
					var local = (pos - wrist_pos) * scale
					local = smooth(index, local)
					thisHandNode.landmarkScenes[index].position = local
					index+=1
				if not thisHandNode.has_origin:
					thisHandNode.origin = wrist_pos
					thisHandNode.has_origin = true
				#offset value is current wristpos - original wrist pos
				var ref = wrist_pos - thisHandNode.origin
				var targetPos : Vector3
				targetPos.x = ref.x * MOVEMENT_MULTIPLIER.x
				targetPos.y = ref.y * MOVEMENT_MULTIPLIER.y
				targetPos.z = -current_size * 5.0 * MOVEMENT_MULTIPLIER.z
				thisHandNode.global_position = thisHandNode.global_position.lerp(
					targetPos,
					0.2 #smooth value, lower = slower
				)

			
