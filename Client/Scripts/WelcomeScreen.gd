extends Control

var PORT=5000
var _client = WebSocketClient.new()

var passwd
func _ready():
	_client.connect("connection_closed",self,"_on_connection_closed")
	_client.connect("connection_failed",self,"_on_connection_failed")
	_client.connect("connection_error",self,"_on_connection_error")
	_client.connect("connection_established",self,"_on_connection_established")
	_client.connect("data_received",self,"_on_data_received")
	
func _on_Proceed_Btn_pressed():
	
	var pin=$VBoxContainer/Panel/VBoxContainer/PanelContainer/VBoxContainer/PinBox.get_text()
	passwd=pin.left(4)
	var octet=pin.trim_prefix(passwd)
	print(passwd,octet)
	var websocket_url = "ws://192.168.1."+octet+":"+str(PORT)
	
	




	var err = _client.connect_to_url(websocket_url)
	if err == OK:
		print("Connected",str(err))
	else:
		print("Unable to connect to",websocket_url)
		
		_client.disconnect_from_host()
		set_process(false)

func _on_connection_closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	_client.disconnect_from_host()
	set_process(false)

func _on_connection_failed():
	print("Failure")
	_client.disconnect_from_host()

func _on_connection_error():
	print("Errored Out")
	
func _on_connection_established(proto = ""):
	print("Connected with protocol: ", proto,passwd)
	_client.get_peer(1).put_packet(passwd.to_utf8())

func _on_data_received():
	var response=_client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", response)
	if(response=="Password Successful"):
		print("Password Matched Successfully")

func _process(delta):
	_client.poll()

func _send():
	_client.get_peer(1).put_packet(JSON.print({"test":"testtt"}).to_utf8())




func _on_Button_pressed():
	_client.disconnect_from_host()
