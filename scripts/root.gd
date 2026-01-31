extends Node3D

var server : UDPServer
var json : JSON
var hands : Array[Hand]
var handScene = preload("uid://5o3n6j00ljwy")
@onready var camera_3d: Camera3D = $Camera3D
@onready var hand_parent: Node3D = $HandParent

var landmarkScenes = []

func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242)
	json = JSON.new()
	for i in range(21):
		var lm = Landmark.create(i)
		add_child(lm)
		landmarkScenes.append(lm)
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
			var data = json.data
			var handsdata = data["hands"]
			for hand in handsdata:
				var handid = int(hand["hand_id"])
				var landmarks = hand["landmarks"]
				var index = 0
				for landmark in landmarks:
					var pos = Vector3(
						-landmark["x"],
						-landmark["y"],
						landmark["z"]
					)
					landmarkScenes[index].global_position = pos
					index+=1
			
