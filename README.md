# Gamepad Controller Emulator For Android

<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://github.com/zan-keith/PlayPulse-Connect/blob/main/Client/Assets/Logo/lighticon.png"
  alt="Playpulse logo"></a>


</p>

<h3 align="center">Playpulse Connect</h3>
<h5 align="center">Controller Emulator</h5>


<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> 
  Turn your smartphone into a game controller with this simple app! This project utilizes the Godot game engine for the Android client app and a Python server to seamlessly connect your smartphone to your PC.
</p>

## 📝 Table of Contents
- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Todo](#todo)
- [Built With](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>
This project consists of two main components: the client (Android app) and the server. The client is developed using Godot Engine and GDScript, while the server is written in Python. Together, they allow you to use your smartphone as a game controller for your PC.

Behind the scenes, the Python server starts a UDP socket server, waiting for connections from any device within the local IPv4 network at a specified port. The client app can establish a connection with the server using a password, and it sends the UI inputs from your smartphone to the server. The server leverages the vgamepad library to emulate keypresses on your PC, effectively turning your smartphone into a virtual gamepad.

## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Windows PC
- Download and Install the latest release of PlayPulse Desktop application GUI from [here](https://github.com/zan-keith/PlayPulse-Connect/releases).
- The first time you open the application you will have to download the ViGem drivers to emulate the virtual gamepad.
- After installation restart your computer for the effects to take place.
- Open the PlayPulse Desktop.

### Android Device
- Download and Install the latest release of PlayPulse Connect APK from [here](https://github.com/zan-keith/PlayPulse-Connect/releases).
- Open the desktop PlayPulse Desktop Application.
- Open the android app and enter the PIN.
- Press Proceed and Enjoy!.
  
### ⚠️Note
The underlying library only supports windows at the moment. So use a windows PC while running the server app.

---

### Prerequisites <a name = "prereqs"></a>
- Android Smartphone for Client Appp
- Windows PC
- Godot Game Engine
- Python 3
- ViGem Drivers

--

### Installing
Step by step series of Instructions get a development env running.

- Clone the repo
```
git clone https://github.com/zan-keith/PlayPulse-Connect.git
```

Navigate to the installation folder

#### Server Side
- Change Directory
```
cd Server/
```
- Install Requirements
```
pip install -r requirements.txt
```
#### Client Side
- Install Requirements
- Import the Godot project

```
cd Client/
```
- For android export follow these instructions
  - [Google](https://developer.android.com/games/engines/godot/godot-export)
  - [Godot Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)



## 🎈 Usage <a name="usage"></a>
### Python CLI ( Command Line Interface )
- Install the requirements
#### Commands :
```
cd Server/CLI/
python main.py -h
python main.py --ip [your_local_ip_address] --port [custom_port] --pin [4_digit_pin] --autokill [true/false]
```

All are optional arguments
| Commands  | What it does | Usage | DataType |
| ------------- | ------------- | ------------- | ------------- |
| --ip  | Specify the IP address for the socket server. | --ip [yourlocalipaddress]  | String |
| --port  | Specify the port for the socket server to run on. | --port [customport]  | Integer |
| --pin  | Specify the PIN authentication code. ( The code must be 4 digits ). | --pin [4digitpin]  | Integer |
| --autokill  | Automatically closes the server once the client presses disconnect | --autokill [true/false]  | Boolean |
| --timeout  | Specifies the time to automatically close the server due to inactivity | --timeout [seconds]  | Integer |

### Python GUI
- Install the requirements
```
cd "Server/Gui App/"
python main.py
```


### Todo List <a name = "todo"></a>
- Add rumble mechanics. [guide](https://pypi.org/project/vgamepad/#rumble-and-leds).
- Get LED outputs to change the color theme in godot.
- Thats it .. for now

## ⛏️ Built With <a name = "built_using"></a>
- [Python 3.11](https://www.python.org/downloads/) - Server Side
- [Godot](https://godotengine.org/) - Client Interface
- [Vgamepad](https://pypi.org/project/vgamepad/) - Virtual Controller

## ✍️ Author <a name = "authors"></a>
- [@zan-keith](https://github.com/zan-keith) - Idea & Work

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- Hats off to the amazing developers of godot engine
- The magic of [Vgamepad](https://pypi.org/project/vgamepad/) module and [ViGem C++](https://github.com/ViGEm) framework
