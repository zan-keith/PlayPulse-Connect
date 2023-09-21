extends Control

var Curr_Layout="Default"
var Existing_Layouts:Array=[]
var Curr_Selected_Btn=null

var Dragging=false

var DefaultBtnValues = {
  "LeftStick": { "scale": 1, "pos": [0, 0] },
  "RightStick": { "scale": 1, "pos": [0, 0] },
  "Btn_L": { "scale": 1, "pos": [0, 0] },
  "Btn_R": { "scale": 1, "pos": [0, 0] },
  "Btn_Select": { "scale": 1, "pos": [0, 0] },
  "Btn_Start": { "scale": 1, "pos": [0, 0] },
  "Btn_Pause": { "scale": 1, "pos": [0, 0] },
  "DigitalButtons": { "scale": 1, "pos": [0, 0] },
  "Dpad": { "scale": 1, "pos": [0, 0] }
};


# When Add Layout is Pressed
func _on_Add_pressed():
	$CreateLayoutPopup.popup()


# Touch outside the Modal dismiss
func _on_ColorRect_gui_input(event):
	if event is InputEventScreenTouch:
		_close_popups()
# Close Btn Press
func _on_Close_pressed():
	_close_popups()

func _on_SelectLayout_ColorRect_gui_input(event):
	if event is InputEventScreenTouch:
		_close_popups()
func _on_SelectLayout_Close_pressed():
	_close_popups()
	






func save_curr_layout():
	var LayoutName=$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.get_text()
	
	var Data=load_file()
	Data= Data if typeof(Data)==TYPE_DICTIONARY else {} 
	var ValuesDictionary:Dictionary ={}
	for child in $".".get_children():
		if child.is_in_group('btn'):
			ValuesDictionary[child.name]={"rect_scale":child.rect_scale,"rect_position":child.rect_position}
			
	Data[LayoutName]=ValuesDictionary
	var file = File.new()
	file.open(Global.LAYOUT_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	print("-- Saved --")

func delete_curr_layout():
	var layout=$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.get_text()
	var Data=load_file()
	Data.erase(layout)
	print(Data)
	var file = File.new()
	file.open(Global.LAYOUT_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	
func load_file(file_name=Global.LAYOUT_FILE_PATH):
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
		

func load_and_set_layout(layout):
	
	$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.set_text(layout)
	var Data=load_file()
	Data= Data if typeof(Data)==TYPE_DICTIONARY else {} 
	if not Data.has(layout):
		save_curr_layout()
		load_and_set_layout(layout)
	else:
		for btn in Data[layout]:
			for field in Data[layout][btn]:
				if $".".get_node(btn)[str(field)]!=null:# Just a Failsafe
					$".".get_node(btn)[str(field)]=str2var("Vector2" + Data[layout][btn][field])

func _close_popups():
	$SelectLayout.hide()
	$CreateLayoutPopup.hide()
	
	for child in $SelectLayout/Panel/VBoxContainer/VBoxContainer.get_children():
		$SelectLayout/Panel/VBoxContainer/VBoxContainer.remove_child(child)
	


	
	

func _on_LayoutSelect_pressed():
	# Displays all existing layouts as a list of buttons
	# Also Binds the button to _on_layout_selected
	$SelectLayout.popup()
	for layout in Existing_Layouts:
		var layout_option_btn= load("res://Scenes/Components/LayoutOptionBtn.tscn").instance()
		layout_option_btn.set_text(layout)
		layout_option_btn.name=layout
		layout_option_btn.connect("pressed",self,"_on_layout_selected",[layout_option_btn.name])
		$SelectLayout/Panel/VBoxContainer/VBoxContainer.add_child(layout_option_btn)
		


func _on_layout_selected(name):
	Curr_Layout=name
	$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.set_text(name)
	_handle_toggle(null,null,true)
	_close_popups()
	load_and_set_layout(Curr_Layout)




func _ready():
	$AnimationPlayer.play("startup")
	# Get all button's child 'Selection' and bind the toggle signal to _handle_toggle()
	for child in $".".get_children():
		if child.is_in_group('btn'):
			child.get_node("Selection").connect("toggled",self,"_handle_toggle",[child])
			child.get_node("Selection").connect("button_down",self,"_button_on_press",[child])
			child.get_node("Selection").connect("button_up",self,"_button_on_release",[child])
			
			
	var Data=load_file()
	Data= Data if typeof(Data)==TYPE_DICTIONARY else {} 
	for layouts in Data:
		Existing_Layouts.append(layouts)
	if len(Existing_Layouts)>0:
		_on_layout_selected(Existing_Layouts[0])
	else:
		_on_layout_selected("Default")
		Existing_Layouts.append("Default")

# If there is nothing selected then show no options
func _btn_selection_onchange():
	if Curr_Selected_Btn==null:
		$ControlPanel/VBoxContainer/Options.hide()
	else:
		$ControlPanel/VBoxContainer/Options.visible=true
		print((Curr_Selected_Btn.rect_position.x*100)/(OS.get_window_safe_area().size.x-Curr_Selected_Btn.rect_size.x))
		$ControlPanel/VBoxContainer/Options/Scale.value=(Curr_Selected_Btn.rect_scale.x*100)/2
		$ControlPanel/VBoxContainer/Options/XPos.value=(Curr_Selected_Btn.rect_position.x*100)/(OS.get_window_safe_area().size.x-Curr_Selected_Btn.rect_size.x)
		$ControlPanel/VBoxContainer/Options/YPos.value=(Curr_Selected_Btn.rect_position.y*100)/(OS.get_window_safe_area().size.y-Curr_Selected_Btn.rect_size.y)
		
		

# All buttons toggles are handled here
# When a selected btn has changed the outline color and Curr_Selected_Btn changes
func _handle_toggle(btn_pressed,btn,reset=false):
	if reset==true and Curr_Selected_Btn!=null:
		Curr_Selected_Btn.get_node("ReferenceRect").border_color=Color.red
		Curr_Selected_Btn.get_node("Selection").pressed=false
		Curr_Selected_Btn=null
		_btn_selection_onchange()
	else:
		if btn_pressed==true and Curr_Selected_Btn!=null:
			var Prev_Selected_Btn=Curr_Selected_Btn
			Curr_Selected_Btn=btn
			btn.get_node("ReferenceRect").border_color=Color.aqua
			Prev_Selected_Btn.get_node("Selection").pressed=false
			Prev_Selected_Btn.get_node("ReferenceRect").border_color=Color.red
			_btn_selection_onchange()
		elif btn_pressed==true and Curr_Selected_Btn==null:
			Curr_Selected_Btn=btn
			btn.get_node("ReferenceRect").border_color=Color.aqua
			_btn_selection_onchange()
		elif btn_pressed==false and Curr_Selected_Btn==btn and not Dragging:
			Curr_Selected_Btn=null
			btn.get_node("ReferenceRect").border_color=Color.red
			_btn_selection_onchange()



func _on_Scale_value_changed(value):
	var scale=(value/100)*2
	Curr_Selected_Btn.rect_scale=Vector2((value/100)*2,(value/100)*2)
	$ControlPanel/VBoxContainer/Options/Title2.set_text("Scale  %3.2f" % [(value/100)*2])
	$ControlPanel/VBoxContainer/BtnGroup.visible=true


func _on_XPos_value_changed(value):
	var Rect_size:Vector2 =Curr_Selected_Btn.rect_size*Curr_Selected_Btn.rect_scale.x # Cannot get the plain rect size because it doesnt resize as the scale scale changes
	Curr_Selected_Btn.rect_position=Vector2((value/100)*(OS.get_window_safe_area().size.x-Rect_size.x),Curr_Selected_Btn.rect_position.y)
	$ControlPanel/VBoxContainer/Options/Title3.set_text("X Pos  %d" % [(value/100)*(OS.get_window_safe_area().size.x-Rect_size.x)])
	$ControlPanel/VBoxContainer/BtnGroup.visible=true
	

func _on_YPos_value_changed(value):
	var Rect_size:Vector2 =Curr_Selected_Btn.rect_size*Curr_Selected_Btn.rect_scale.x
	Curr_Selected_Btn.rect_position=Vector2(Curr_Selected_Btn.rect_position.x,(value/100)*(OS.get_window_safe_area().size.y-Rect_size.y))
	$ControlPanel/VBoxContainer/Options/Title4.set_text("Y Pos %d" % [(value/100)*(OS.get_window_safe_area().size.y-Rect_size.y)])
	$ControlPanel/VBoxContainer/BtnGroup.visible=true
	

func _on_Save_pressed():
	save_curr_layout()


func _on_Create_pressed():
	var layout_name=$CreateLayoutPopup/Panel/VBoxContainer/LayoutName.get_text()
	if not Existing_Layouts.has(layout_name):
		Existing_Layouts.append(layout_name)
		_on_layout_selected(layout_name)
	else:
		$CreateLayoutPopup/Panel/VBoxContainer/Error.set_text("Layout Already Exists - Choose a different name")
		$CreateLayoutPopup/Panel/VBoxContainer/Error.visible=true
	


func _on_Delete_Layout_pressed():
	var layout_name=$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.get_text()
	if layout_name!="Default":
		delete_curr_layout()
		Existing_Layouts.remove(Existing_Layouts.find(layout_name))
		_on_layout_selected("Default")


func _on_Cancel_pressed():
	_handle_toggle(null,null,true)
	$ControlPanel/VBoxContainer/Options.hide()
	$ControlPanel/VBoxContainer/BtnGroup.hide()


func _on_GoBack_pressed():
	var Prefs=load_file()
	
	# Error Handling : if settings file corruption or smthin
	if typeof(Prefs)==TYPE_DICTIONARY:
		var layout_name=$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.get_text()
		Prefs["Layout"]=layout_name
	else:
		Prefs=Global.DefaultSettings

	var file = File.new()
	file.open(Global.USER_PREFS_FILE_PATH, File.WRITE)
	file.store_string(to_json(Prefs))
	file.close()
	Global.UserSettings=Prefs
	get_tree().change_scene("res://Scenes/Pages/GamePad.tscn")

func _process(delta):
	if Dragging:
		var Rect_size:Vector2 =Curr_Selected_Btn.rect_size*Curr_Selected_Btn.rect_scale.x
		Curr_Selected_Btn.rect_position=get_global_mouse_position()-Rect_size/2

func _button_on_press(btn):
	btn.modulate=Color.from_hsv(0, 0, 0.5, 0.5)
	Dragging=true
	set_process(true)
	
func _button_on_release(btn):
	btn.modulate=Color.from_hsv(0, 0, 1, 1)
	Dragging=false
	set_process(false)


