extends Control

var connected = false
var udp := PacketPeerUDP.new()

export onready var ADDRESS="none"
var UserSettings: Dictionary={}
var prev_val=Vector3.ZERO
export var step=0.05

signal force_rect_change_for_sticks
export var sensitivity = 1.8 # increases sentivity

var u = Vector3.ZERO

func set_save_data():
	$RightStick.joystick_mode=$RightStick.JoystickMode.DYNAMIC if Global.UserSettings["DynamicJoystickR"] else $RightStick.JoystickMode.FIXED
	
	
	if Global.UserSettings["Gyro"]:
		set_process(true)
	else:
		set_process(false)
	
	sensitivity=Global.UserSettings["GyroSensitivity"] if Global.UserSettings.has("GyroSensitivity") else 1


func _ready():

	load_user_prefs()
	set_save_data()
	load_and_set_layout(Global.UserSettings["Layout"])
	emit_signal("force_rect_change_for_sticks")
	$AnimationPlayer.play("startup2")
	print(":::: ",Global.UserSettings["Layout"])
	

	
	var IP_ADDRESS=Global.IP_ADDRESS
	var PORT=Global.PORT
	
	print(IP_ADDRESS)
	var err=udp.connect_to_host(IP_ADDRESS, PORT)
	if err!=OK:
		_on_Disconnect_pressed()
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
				if typeof($".".get_node(btn)[str(field)])==5:
					$".".get_node(btn)[str(field)]=str2var("Vector2" + Data[layout][btn][field])

					
				elif typeof($".".get_node(btn)[str(field)])==14:
					$".".get_node(btn)[str(field)].a=float(Data[layout][btn][field].split(",")[3])
				elif typeof($".".get_node(btn)[str(field)])==1:
					
					$".".get_node(btn)[str(field)]=Data[layout][btn][field]

	else:
		pass # If Layout is not found then just use the layout from godot scene by default

func save_session_file(Data):
	var file = File.new()
	file.open(Global.SESSION_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	print("-- Saved --")

func _on_Left_Stick_joystick_input_update(pos):
	pos=pos[0]
	print(pos)
	udp.put_packet(("LJ%6.3f,%6.3f"%[pos.x,-pos.y]).to_utf8())


func _on_Right_Stick_joystick_input_update(pos):
	pos=pos[0]
	print(pos)
	udp.put_packet(("RJ%6.3f,%6.3f"%[pos.x,-pos.y]).to_utf8())

func _on_LEFT_TRIGGER_pressed():
	udp.put_packet(("LT1").to_utf8())


func _on_LEFT_TRIGGER_released():
	udp.put_packet(("LT0").to_utf8())


func _on_RIGHT_TRIGGER_pressed():
	udp.put_packet(("RT1").to_utf8())


func _on_RIGHT_TRIGGER_released():
	udp.put_packet(("RT0").to_utf8())

func _on_btn_press(c):
	if Global.UserSettings["Vibration"]:
		Input.vibrate_handheld(1)
	if Global.UserSettings["Sound"]:
		$PressSound.play()
	
#	udp.put_packet(str("press:"+c.name).to_utf8())
	udp.put_packet(str("P"+c.name).to_utf8()) #p for press
	


func _on_btn_release(c):
	if Global.UserSettings["Sound"]:
		$ReleaseSound.play()
	udp.put_packet(str("R"+c.name).to_utf8())#r for release







func _on_Settings_pressed():
	get_tree().change_scene("res://Scenes/Pages/SettingsPage.tscn")



func _on_Disconnect_pressed():
	save_session_file({"IP":""})
	udp.put_packet("ENDCONN".to_utf8())
	get_tree().change_scene("res://Scenes/Pages/WelcomeScreen.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="startup2":
		$AnimationPlayer.play("glowup")
		$AnimationPlayer.queue("show_control_panel")
		






func _on_HomeBtn_toggled(button_pressed):
	if button_pressed:
		$AnimationPlayer.play("show_control_panel")
	else:
		$AnimationPlayer.play("hide_control_panel")


func _process(delta):
#	var gyro=Input.get_accelerometer()
#	gyro.x+=0
#	gyro.y+=0
#
#	velocity = prev_val.linear_interpolate(gyro,acceleration)
#	velocity=(velocity.normalized()*sensitivity)
#
#	#Clamp it
#	udp.put_packet(("RJ%6.3f,%6.3f"%[min(max(velocity.x, -1), 1),-min(max(velocity.y, -1), 1)]).to_utf8())
#	prev_val=velocity



#-------------------------------
#	var v=Input.get_accelerometer()
#
#	var accelerationV=u.linear_interpolate(v,0.05)
#	var deltaA=accelerationV-accelerationU
#
#	udp.put_packet(("RJ%6.3f,%6.3f"%[min(max(deltaA.x, -1), 1),min(max(deltaA.y, -1), 1)]).to_utf8())
#
#	accelerationU=accelerationU.linear_interpolate(accelerationV,0.05)
#
#
#
#
#	u=v
#-------------------------------------


	
	
	var v=Input.get_accelerometer().normalized()*sensitivity
	
	$SubTitle.text=str(stepify(v.x,0.1))
	$SubTitle2.text=str(stepify(v.y,0.1))
	$SubTitle3.text=str(stepify(v.z,0.1))
	
	
	








func _on_RightStick_joystick_release(pos):
	if Global.UserSettings["Gyro"]:
		set_process(true)


func _on_RightStick_joystick_press():
	if Global.UserSettings["Gyro"]:
		set_process(false)
