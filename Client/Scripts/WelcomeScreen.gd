extends Control

var udp := PacketPeerUDP.new()

var connected = false
var IP_ADDRESS=""

func _ready():
	$AnimationPlayer.play("startup")
	$AnimationPlayer.queue("gradientflow")

	# set all linkbuttons with onpress binding, just another fancy way for connecting signals
	var LinkBtnArray=[$VBoxContainer/TextureRect/Links/LinkButton]
	for child in LinkBtnArray:
		if child is LinkButton:
			child.connect("pressed",self,"_link_pressed",[child])
	
	# Check if session is closed
	var LastSession=load_file()
	if typeof(LastSession) == TYPE_DICTIONARY:
		if LastSession.has("IP") and LastSession["IP"]!="":
			var pin="PING"
			var pwd=pin.left(4)
			IP_ADDRESS=LastSession["IP"]
			udp.connect_to_host(IP_ADDRESS, 5000)
			udp.put_packet(pwd.to_utf8())
		elif not LastSession.has("IP"):
			corruption_fix()
	else:
		corruption_fix()
	
	
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
		print('= ',response)
		if (response=="authenticated" or response=="received"):
			Global.IP_ADDRESS=IP_ADDRESS
			save_file({"IP":IP_ADDRESS})
			print("CHANGING SCENES")
			get_tree().change_scene("res://Scenes/Pages/GamePad.tscn")

func load_file(file_name=Global.SESSION_FILE_PATH):
	var file = File.new()
	if file.file_exists(file_name):
		file.open(file_name, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			printerr("Corrupted data!")
			return null
	else:
		printerr("No saved data!")
		return null


func corruption_fix():
	var file = File.new()
	file.open(Global.SESSION_FILE_PATH, File.WRITE)
	file.store_string(to_json(Global.DefaultSession))
	file.close()
	print("-- Fixed --")


func save_file(Data):
	var file = File.new()
	file.open(Global.SESSION_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	print("-- Saved --")


func _on_PinBox_text_entered(new_text):
	_on_Proceed_pressed()


func _link_pressed(btn):
	OS.shell_open(btn.text)
