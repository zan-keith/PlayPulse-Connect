extends Node

var LAYOUT_FILE_PATH="user://LayoutsData.json"
var USER_PREFS_FILE_PATH="user://UserPrefs.json"
var SESSION_FILE_PATH="user://Session.json"

var IP_ADDRESS=""
var DefaultSettings={
	"Layout":"Default",
	"Sound":true,
	"Vibration":true,
	"PassbyPress":false,
	"DynamicJoystickR":false,
	"Gyro":false,
	"GyroSensitivity":1
}

var DefaultLayoutSettings={
  "Default": {
	"BACK": {  "rect_scale": "(1, 1)" },
	"DPad": { "rect_scale": "(1, 1)" },
	"GUIDE": { "rect_scale": "(1, 1)" },
	"LEFT_SHOULDER": { "rect_scale": "(1, 1)" },
	"LEFT_THUMB": { "rect_scale": "(1, 1)" },
	"LeftStick": { "rect_scale": "(1, 1)" },
	"RIGHT_SHOULDER": {  "rect_scale": "(1, 1)" },
	"RIGHT_THUMB": { "rect_scale": "(1, 1)" },
	"RightStick": { "rect_scale": "(1, 1)" },
	"START": { "rect_scale": "(1, 1)" },
  }
}

var BtnsLayoutPropertyDataTypes={
	
	"Vector2":["rect_scale","rect_position"],
	"bool":["visible"]
	
}
var UserSettings: Dictionary={
	
}

var DefaultSession={
	"IP":"",
}

var LINKS={
	"github":"https://github.com/Alpha-Hunt/GamePadPortal",
	"itch":"https://captain-knull.itch.io/",
	"godot":"https://godotengine.org/",
}
