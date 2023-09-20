extends Control

var Curr_Layout="Default"
var Existing_Layouts=["Default",'asd']
var Curr_Selected_Btn=null

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
	var ValuesDictionary:Dictionary ={}
	for child in $".".get_children():
		if child.is_in_group('btn'):
			ValuesDictionary[child]={"rect_scale":child.rect_scale,"rect_position":child.rect_position}
#	var config = ConfigFile.new()
#	for fields in CurrLayoutValues:
#
#		config.set_value(Curr_Layout, fields, CurrLayoutValues[fields])
#
#	config.save("user://Layouts.cfg")
	print(LayoutName,ValuesDictionary)
	print("-- Saved --")


func _close_popups():
	$SelectLayout.hide()
	$CreateLayoutPopup.hide()
	
	for child in $SelectLayout/Panel/VBoxContainer/VBoxContainer.get_children():
		$SelectLayout/Panel/VBoxContainer/VBoxContainer.remove_child(child)
	

func _load_layout(layout):
	Curr_Layout=layout
	
	$ControlPanel/VBoxContainer/BtnGroup1/LayoutSelect.set_text(Curr_Layout)
	
	

func _on_LayoutSelect_pressed():
	# Displays all existing layouts as a list of buttons
	# Also Binds the button to _on_layout_selected
	$SelectLayout.popup()
	for layout in Existing_Layouts:
		var layout_option_btn= load("res://Scenes/Components/LayoutOptionBtn.tscn").instance()
		layout_option_btn.set_text(layout)
		layout_option_btn.name=layout
		layout_option_btn.connect("pressed",self,"_on_layout_selected",[layout_option_btn])
		$SelectLayout/Panel/VBoxContainer/VBoxContainer.add_child(layout_option_btn)
		


func _on_layout_selected(btn):
	print("Slected ",btn.name)
	_handle_toggle(null,null,true)
	_close_popups()





func _ready():
	# Get all button's child 'Selection' and bind the toggle signal to _handle_toggle()
	for child in $".".get_children():
		if child.is_in_group('btn'):
			child.get_node("Selection").connect("toggled",self,"_handle_toggle",[child])
			print(child.name)

# If there is nothing selected then show no options
func _btn_selection_onchange():
	if Curr_Selected_Btn==null:
		$ControlPanel/VBoxContainer/Options.hide()
	else:
		$ControlPanel/VBoxContainer/Options.visible=true
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
		elif btn_pressed==false and Curr_Selected_Btn==btn:
			Curr_Selected_Btn=null
			btn.get_node("ReferenceRect").border_color=Color.red
			_btn_selection_onchange()



func _on_Scale_value_changed(value):
	var scale=(value/100)*2
	print(scale)
	Curr_Selected_Btn.rect_scale=Vector2((value/100)*2,(value/100)*2)
	$ControlPanel/VBoxContainer/Options/Title2.set_text("Scale  %3.2f" % [(value/100)*2])


func _on_XPos_value_changed(value):
	Curr_Selected_Btn.rect_position=Vector2((value/100)*(OS.get_window_safe_area().size.x-Curr_Selected_Btn.rect_size.x),Curr_Selected_Btn.rect_position.y)
	$ControlPanel/VBoxContainer/Options/Title3.set_text("X Pos  %d" % [(value/100)*(OS.get_window_safe_area().size.x-Curr_Selected_Btn.rect_size.x)])
	


func _on_YPos_value_changed(value):
	Curr_Selected_Btn.rect_position=Vector2(Curr_Selected_Btn.rect_position.x,(value/100)*(OS.get_window_safe_area().size.y-Curr_Selected_Btn.rect_size.y))
	$ControlPanel/VBoxContainer/Options/Title4.set_text("Y Pos %d" % [(value/100)*(OS.get_window_safe_area().size.y-Curr_Selected_Btn.rect_size.y)])


func _on_Save_pressed():
	save_curr_layout()
