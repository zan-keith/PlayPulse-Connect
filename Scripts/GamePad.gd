extends Control

var connected = false
var udp := PacketPeerUDP.new()

export onready var ADDRESS="none"

func _ready():
	var IP_ADDRESS=Global.IP_ADDRESS
	print(IP_ADDRESS)
	udp.connect_to_host(IP_ADDRESS, 5000)


	udp.put_packet("left".to_utf8())











func _on_Virtual_joystick_joystick_input_update(pos):
	udp.put_packet(str(pos).to_utf8())
	
