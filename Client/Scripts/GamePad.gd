extends Control

var connected = false
var udp := PacketPeerUDP.new()

export onready var ADDRESS="none"


func _ready():
	var IP_ADDRESS=Global.IP_ADDRESS
	print(IP_ADDRESS)
	udp.connect_to_host(IP_ADDRESS, 5000)
	udp.put_packet("test".to_utf8())
	
	for child in $".".get_children():
		if child.is_in_group("btn"):
			child.connect("button_down",self,"_on_btn_press",[child])
			child.connect("button_up",self,"_on_btn_release",[child])
		elif child.is_in_group("btn_group"):
			for btn in child.get_children():
				if btn.is_in_group("btn"):
					btn.connect("button_down",self,"_on_btn_press",[child])
					btn.connect("button_up",self,"_on_btn_release",[child])
			


func _on_Left_Stick_joystick_input_update(pos):
	udp.put_packet(str(pos).to_utf8())
	

func _on_btn_press(c):
	$PressSound.play()
	
func _on_btn_release(c):
	$ReleaseSound.play()

func _on_Right_Stick_joystick_input_update(pos):
	udp.put_packet(str(pos).to_utf8())


func _on_Dpad_UP_pressed():
	pass # Replace with function body.


func _on_Dpad_LEFT_pressed():
	pass # Replace with function body.


func _on_Dpad_RIGHT_pressed():
	pass # Replace with function body.


func _on_Dpad_DOWN_pressed():
	pass # Replace with function body.



