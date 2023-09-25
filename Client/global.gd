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
	"github":"https://github.com/zan-keith/PlayPulse-Connect",
	"itch":"https://captain-knull.itch.io/",
	"godot":"https://godotengine.org/",
}
