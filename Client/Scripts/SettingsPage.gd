extends Control

var Settings={}

var CheckBoxes: Array
var Sliders: Array



func _ready():
	$AnimationPlayer.play("startup")
	Settings=load_file()
	Settings=Settings if typeof(Settings)==TYPE_DICTIONARY else Global.DefaultSettings
	CheckBoxes=[$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer/Vibration,$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer2/Sound,$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer4/PassbyPress,$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer5/DynamicJoystickR,$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer6/Gyro]
	Sliders=[$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer7/VBoxContainer/HBoxContainer/GyroSensitivity]
	for sets in CheckBoxes:
		if Settings.has(sets.name):
			sets.pressed=Settings[sets.name]
		else:
			Settings[sets.name]=Global.DefaultSettings[sets.name]
	for sets in Sliders:
		if Settings.has(sets.name):
			sets.value=Settings[sets.name]
		else:
			Settings[sets.name]=Global.DefaultSettings[sets.name]


func load_file(file_name=Global.USER_PREFS_FILE_PATH):
	var file = File.new()
	if file.file_exists(file_name):
		file.open(file_name, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			printerr("Corrupted data!")
			corruption_fix()
			return null
	else:
		printerr("No saved data!")
		corruption_fix()
		return null


func corruption_fix():
	var file = File.new()
	file.open(Global.USER_PREFS_FILE_PATH, File.WRITE)
	file.store_string(to_json(Global.DefaultSettings))
	file.close()
	print("-- Fixed --")


func save_file(Data):
	var file = File.new()
	file.open(Global.USER_PREFS_FILE_PATH, File.WRITE)
	file.store_string(to_json(Data))
	file.close()
	print("-- Saved --")
	



func _on_BackBtn_pressed():
	for sets in CheckBoxes:
		Settings[sets.name]=sets.pressed
	for sets in Sliders:
		Settings[sets.name]=sets.value
		
	save_file(Settings)
	Global.UserSettings=Settings
	get_tree().change_scene("res://Scenes/Pages/GamePad.tscn")


func _on_LayoutSettingsButton_gui_input(event):
	if event.is_pressed():
		for sets in CheckBoxes:
			Settings[sets.name]=sets.pressed
		save_file(Settings)
		Global.UserSettings=Settings
		print("+ ",Settings)
		$AnimationPlayer.play("leftswipe")



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="leftswipe":
		get_tree().change_scene("res://Scenes/Pages/LayoutSettings.tscn")


func _on_Sensitivity_value_changed(value):
	$PanelContainer/ScrollContainer/VBoxContainer/HBoxContainer7/VBoxContainer/HBoxContainer/Value.text=str(value)
