extends Control

var udp := PacketPeerUDP.new()

var connected = false
var IP_ADDRESS=""
var PORT=5000


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
			var pin="ping"
			var pwd=pin.left(4)
			IP_ADDRESS=LastSession["IP"]
			udp.connect_to_host(IP_ADDRESS, PORT)
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
	var pin=$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/PinBox.get_text()
	var pwd=pin.left(4)
	var octet=pin.trim_prefix(pwd)
	PORT=5000
	
	if $VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/HBoxContainer/CheckBox.pressed:#if manually typed the IP
		if len($VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/IPBox.text) > 7:
			IP_ADDRESS=$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/IPBox.text

		else:
			show_error("IP is Invalid","Verify the IP from your PC or try disabling Advanced Settings.")

		if len($VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/PortBox.text)>1:
			PORT=int($VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/PortBox.text)
	else:
		IP_ADDRESS='192.168.1.'+octet

	if len($VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/PinBox.text)<5:
		show_error("Enter a valid PIN","Verify the pin number from your PC.")
		return null
	print(IP_ADDRESS)
	

		
	var err=udp.connect_to_host(IP_ADDRESS, int(PORT))
	udp.put_packet("ping".to_utf8())
	if err!=OK:
		show_error("Couldn't establish a connection with the IP %s" % IP_ADDRESS,"Check the ip address from your PC and try connecting with Advanced Settings.")
	udp.put_packet(pwd.to_utf8())

func show_error(title,sub):
	$ErrorPopup/PinCard/VBoxContainer/Title.text=title
	$ErrorPopup/PinCard/VBoxContainer/SubTitle.text=sub
	$ErrorPopup.popup()
	
func _process(delta):
	if udp.get_available_packet_count()>0:
		var response=udp.get_packet().get_string_from_utf8()
		print('= ',response)
		if response=="pong":
			change_server_status_label("Server Active")
		elif (response=="authenticated" or response=="received"):
			Global.IP_ADDRESS=IP_ADDRESS
			Global.PORT=PORT
			save_file({"IP":IP_ADDRESS})
			print("CHANGING SCENES")
			get_tree().change_scene("res://Scenes/Pages/GamePad.tscn")
		elif (response=="wrong password"):
			show_error("Wrong PIN for %s" % IP_ADDRESS,"Verify the pin number and ip address from your PC or try manual Advanced Settings.")
		elif (response=="another device"):
			show_error("Couldn't establish a connection with the IP %s because another device is already connected" % IP_ADDRESS,"Disconnect the connected device.\n Check the ip address from your PC .\n If the issue still persists restart the server.")
			

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
	$Overlay.hide()
	_on_Proceed_pressed()


func _link_pressed(btn):
	OS.shell_open(btn.text)


func _on_Ok_Close_Error_pressed():
	$ErrorPopup.hide()


func _on_SubTitle_gui_input(event):
	if event.is_pressed():
		$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/HBoxContainer/CheckBox.pressed=not $VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/HBoxContainer/CheckBox.pressed


func _on_Advanced_Settings_CheckBox_toggled(button_pressed):
	if button_pressed:
		$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings.visible=true
	else:
		$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings.visible=false
		

func _on_PortBox_text_changed(new_text):
	PORT=int(new_text)
	var err=udp.connect_to_host(IP_ADDRESS, PORT)
	if err==OK:
		udp.put_packet("supersecretpingmsg".to_utf8())
	
	change_server_status_label("Server Inactive")

func _on_PinBox_text_changed(new_text):
	var pin=new_text
	var pwd=pin.left(4)
	var octet=pin.trim_prefix(pwd)
	
	IP_ADDRESS='192.168.1.'+octet
	var err=udp.connect_to_host(IP_ADDRESS, PORT)
	if err==OK:
		udp.put_packet("supersecretpingmsg".to_utf8())
	
	change_server_status_label("Server Inactive")

func _on_IPBox_text_changed(new_text):
	IP_ADDRESS=new_text
	var err=udp.connect_to_host(IP_ADDRESS, PORT)
	if err==OK:
		udp.put_packet("supersecretpingmsg".to_utf8())
	
	change_server_status_label("Server Inactive")
	
#Escape KeyPress
func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		$Overlay.hide()
		$ErrorPopup.hide()

func change_server_status_label(msg):
	$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/ServerStatus.text=msg
	$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/ServerStatus.modulate=Color.red if msg=="Server Inactive" else Color.green
	$Overlay/OServerStatus.text=msg
	$Overlay/OServerStatus.modulate=Color.red if msg=="Server Inactive" else Color.green




# To fix the android keyboard covering issue

#From HERE ----------------------------------------------------->

func hide_textboxes_except(box=null):
	for ch in $Overlay.get_children():
		ch.visible=false
	if box:
		$Overlay.visible=true
		box.visible=true
		box.grab_focus()
	else:
		$Overlay.visible=false
	$Overlay/OServerStatus.visible=true

		
func _on_PinBox_focus_entered():
	hide_textboxes_except($Overlay/OPinBox)
func _on_IPBox_focus_entered():
	hide_textboxes_except($Overlay/OIPBox)
func _on_PortBox_focus_entered():
	hide_textboxes_except($Overlay/OPort)



func _on_OPinBox_text_entered(new_text):
	hide_textboxes_except()
func _on_OIPBox_text_entered(new_text):
	hide_textboxes_except()
func _on_OPort_text_entered(new_text):
	hide_textboxes_except()


func _on_OPinBox_text_changed(new_text):
	$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/PinBox.set_text(new_text)
	_on_PinBox_text_changed(new_text)
func _on_OIPBox_text_changed(new_text):
	$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/IPBox.set_text(new_text)
	_on_IPBox_text_changed(new_text)
func _on_OPort_text_changed(new_text):
	$VBoxContainer/Panel/VBoxContainer/ScrollContainer/PinCard/VBoxContainer/AdvancedSettings/VBoxContainer/PortBox.set_text(new_text)
	_on_PortBox_text_changed(new_text)













