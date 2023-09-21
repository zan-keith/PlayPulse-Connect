extends Control

export var Redirect=true
var connected = false
var udp := PacketPeerUDP.new()

export onready var ADDRESS="none"
var UserSettings: Dictionary={}

func _ready():
	load_user_prefs()
	load_and_set_layout(Global.UserSettings["Layout"])
	
	print(":::: ",Global.UserSettings["Layout"])
	$AnimationPlayer.play("startup")
	$AnimationPlayer.queue("glowup")
	

	
	var IP_ADDRESS=Global.IP_ADDRESS
	print(IP_ADDRESS)
	var err=udp.connect_to_host(IP_ADDRESS, 5000)
	if err!=OK and Redirect:
		_on_Disconnect_pressed()
	udp.put_packet("test".to_utf8())
	
	for child in $".".get_children():
		if child.is_in_group("btn"):
			
			apply_btn_settings(child)

			child.connect("pressed",self,"_on_btn_press",[child])
			child.connect("released",self,"_on_btn_release",[child])
		elif child.is_in_group("btn_group"):
			for btn in child.get_children():
				if btn.is_in_group("btn"):
					apply_btn_settings(btn)
					
					btn.connect("pressed",self,"_on_btn_press",[btn])
					btn.connect("released",self,"_on_btn_release",[btn])
					
func apply_btn_settings(btn):
	var passbyPress = Global.UserSettings["PassbyPress"] if Global.UserSettings.has("PassbyPress") else Global.DefaultSettings["PassbyPress"]
	btn.set_passby_press(passbyPress)


func load_file(file_name):
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
		
func load_user_prefs():
	var Prefs=load_file(Global.USER_PREFS_FILE_PATH)
	
	# Error Handling : if settings file corruption or smthin
	if typeof(Prefs)!=TYPE_DICTIONARY:

		Prefs=Global.DefaultSettings

		var file = File.new()
		file.open(Global.USER_PREFS_FILE_PATH, File.WRITE)
		file.store_string(to_json(Prefs))
		file.close()
	Global.UserSettings=Prefs

func load_and_set_layout(layout):
	var Data=load_file(Global.LAYOUT_FILE_PATH)
	Data= Data if typeof(Data)==TYPE_DICTIONARY else {} 
	
	if Data.has(layout):
		for btn in Data[layout]:
			for field in Data[layout][btn]:
				pass
				$".".get_node(btn)[str(field)]=str2var("Vector2" + Data[layout][btn][field])
	else:
		pass #If Layout is not found then just use the layout from godot scene by default

func save_session_file(Data):
	var file = File.new()
	file.open(Global.SESSION_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	print("-- Saved --")

func _on_Left_Stick_joystick_input_update(pos):
	udp.put_packet(str(pos).to_utf8())
	

func _on_btn_press(c):
	if Global.UserSettings["Vibration"]:
		Input.vibrate_handheld(1)
	if Global.UserSettings["Sound"]:
		$PressSound.play()
	
func _on_btn_release(c):
	if Global.UserSettings["Sound"]:
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





func _on_Settings_pressed():
	get_tree().change_scene("res://Scenes/Pages/SettingsPage.tscn")



func _on_Disconnect_pressed():
	save_session_file({"IP":""})
	udp.put_packet("ENDCONN".to_utf8())
	get_tree().change_scene("res://Scenes/Pages/WelcomeScreen.tscn")
