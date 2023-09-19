extends Control

var udp := PacketPeerUDP.new()

var connected = false
var IP_ADDRESS=""

func _ready():
	$AnimationPlayer.play("startup")
	
	
	

func _on_Proceed_pressed():
	var pin=$VBoxContainer/Panel/VBoxContainer/PanelContainer/VBoxContainer/PinBox.get_text()
	var pwd=pin.left(4)
	var octet=pin.trim_prefix(pwd)
	IP_ADDRESS="192.168.1."+octet
	udp.connect_to_host(IP_ADDRESS, 5000)


	udp.put_packet(pwd.to_utf8())

	
	

func _process(delta):
	if udp.get_available_packet_count()>0:
		var response=udp.get_packet().get_string_from_utf8()
		print(response)
		if (response=="authenticated"):
			Global.IP_ADDRESS=IP_ADDRESS
			print("CHANGING SCENES")
			get_tree().change_scene("res://Scenes/GamePad.tscn")






func _on_Button_pressed():
	print("pressed")
	var msgbox=$VBoxContainer/Panel/VBoxContainer/PanelContainer/VBoxContainer/msg.get_text()
	udp.put_packet(msgbox.to_utf8())





func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="startup":
		$AnimationPlayer.play("gradientflow")
		
