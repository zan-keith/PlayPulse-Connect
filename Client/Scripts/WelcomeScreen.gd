extends Control

var udp := PacketPeerUDP.new()

var connected = false
var IP_ADDRESS=""

func _ready():
	$AnimationPlayer.play("startup")
	$AnimationPlayer.queue("gradientflow")
	var username
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	else:
		username = "Player"
	$VBoxContainer/Panel/VBoxContainer/UserName.set_text(username)
	$VBoxContainer/Panel/Avatar/RLabel5.set_bbcode("[center]"+username.left(2).to_upper())
	
	

func _on_Proceed_pressed():
	var pin=$VBoxContainer/Panel/VBoxContainer/PinCard/VBoxContainer/PinBox.get_text()
	var pwd=pin.left(4)
	var octet=pin.trim_prefix(pwd)
	IP_ADDRESS="192.168.1."+octet
	udp.connect_to_host(IP_ADDRESS, 5000)


	udp.put_packet(pwd.to_utf8())

	
	

func _process(delta):
	if udp.get_available_packet_count()>0:
		var response=udp.get_packet().get_string_from_utf8()
		print(response)
		if (response=="authenticated" or response=="received"):
			Global.IP_ADDRESS=IP_ADDRESS
			print("CHANGING SCENES")
			get_tree().change_scene("res://Scenes/Pages/GamePad.tscn")












		


func _on_PinBox_text_entered(new_text):
	_on_Proceed_pressed()
