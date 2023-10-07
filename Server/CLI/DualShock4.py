"""
Author: @zan-keith
Github:

PlayPulse Connect CLI

The program contains:
- Code that connects a virtual game controller using the functionality from the vgamepad Python module.
- Code that initializes a socket server on your PC at the preferred port.

PS :
This program is only possible because of the wonderful developers of vgamepad,ViGemBus and Godot.
Visit their works through these links.

https://github.com/yannbouteiller/vgamepad
https://github.com/nefarius/ViGEmBus
https://godotengine.org/
"""

import argparse
import random
import socket
import sys
import time

import logging
import threading
import keyboard

try:
    import vgamepad as vg
except:
    logging.error("Couldn't load ViGemBus bus drivers. These drivers are necessary to emulate the virtual gamepad .")
    print("Install ViGemBus drivers from this link https://github.com/nefarius/ViGEmBus/releases")
    input("")
    sys.exit()

parser = argparse.ArgumentParser(description="GamePadPortal")

parser.add_argument("--ip", metavar="ip", type=str, required=False,
                    help="Specify the IP address for the socket server.")
parser.add_argument("--port", metavar="port", type=int, required=False,
                    help="Specify the port for the socket server to run on.")
parser.add_argument("--pin", metavar="pin", type=int, required=False,
                    help="Specify the PIN authentication code. ( The code must be 4 digits ).")
parser.add_argument("--autokill", metavar="autokill", type=bool, required=False,
                    help="Automatically closes the server once the client presses disconnect.")
parser.add_argument("--timeout", metavar="timeout", type=int, required=False,
                    help="Specifies the time to automatically close the server due to inactivity.")

args = parser.parse_args()

arg_ip_address = args.ip
arg_port = args.port
arg_autokill = args.autokill if args.autokill else True
arg_timeout = args.timeout if args.timeout else 200  # CNAHE
arg_pin = args.pin


# Idk if there is a better way to get the address
def get_host_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        wifi_ip = s.getsockname()[0]
        s.close()
        return wifi_ip
    except Exception as e:
        print(f"Couldnt get the Local IP Address \n {e}")
        sys.exit()



stop_listener = False


# Function to listen for the key combination
def listener_thread():
    global stop_listener
    while True:
        if keyboard.is_pressed('ctrl+alt+c'):
            logging.warning("Terminating the server...")
            socket.close()
            stop_listener = True
            break
        time.sleep(0.1)


HOST_ADDRESS = arg_ip_address if arg_ip_address else get_host_ip()
PORT = arg_port if arg_port else 5000

if PORT < 5000:
    logging.warning(
        "Warning:\n If you are not using the default port numbers, use the higher port numbers to avoid unexpected behavior")
    if input(f"Do you want to continue with the port number {PORT} ? [y/N]").upper() != "Y":
        sys.exit()

gamepad = vg.VDS4Gamepad()



hostname = socket.gethostname()

socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
authenticated = [False, None]
address = None
conn = False
prev_vibration=0
def my_callback(client, target, large_motor, small_motor, led_number, user_data):
    global prev_vibration
    if authenticated[0] and large_motor!=prev_vibration:
        socket.sendto(f"VIB{large_motor}".encode('utf-8'), address)
        prev_vibration=large_motor
while (not conn):
    try:
        socket.bind((HOST_ADDRESS, PORT))
        socket.settimeout(arg_timeout)
        conn = True
    except OSError as e:
        if e.errno == 10048:
            print(
                f"A socket is already opened in port number {PORT}.\nContinue and try connecting to the next port number?[Y/n]")
            decision = input("").lower()
            if decision == "y" or not decision:
                PORT += 1
                print(f"Trying PORT :{PORT}")
            else:
                print("Closing the program")
                sys.exit()

print(f"SERVER IS RUNNING IN DEVICE {hostname} WITH IP {HOST_ADDRESS} SOCKET IN PORT {PORT}")
octets = HOST_ADDRESS.split(".")
fourth_octet = octets[3]

pin = arg_pin if (arg_pin and len(str(arg_pin)) == 4) else random.randint(1000, 9999)
print(f"PIN: {pin}{fourth_octet}")
print("Press Ctrl + Alt + C to exit the program")

# Start the listener thread
listener = threading.Thread(target=listener_thread)
listener.daemon = True
listener.start()

def register_notification_in_thread():
    gamepad.register_notification(callback_function=my_callback)
notification_thread = threading.Thread(target=register_notification_in_thread)
notification_thread.start()
while True:

    if stop_listener:
        break
    try:
        msg, address = socket.recvfrom(1024)
    except OSError as e:
        if e.errno == 10038:
            break
        else:
            logging.error(e)
    if msg.decode("utf-8") == "supersecretpingmsg":
        socket.sendto("pong".encode('utf-8'), address)

    elif authenticated[0] and authenticated[1] == address[0]:
        msg = msg.decode("utf-8")
        if msg == "ENDCONN" and arg_autokill:
            logging.warning("Connection Ended By The Client")
            authenticated = [False, None]
            socket.close()
            sys.exit()
        if msg == "whichcontroller":
            socket.sendto("DS4".encode('utf-8'), address)
        if msg[0:2] == "LJ":
            gamepad.left_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
        elif msg[0:2] == "RJ":
            gamepad.right_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
        elif msg[0:4] == "LTRG":
            gamepad.left_trigger_float(value_float=float(msg[4:]))
        elif msg[0:4] == "RTRG":
            gamepad.right_trigger_float(value_float=float(msg[4:]))
        elif msg[0] == "P":
            if(msg[1:5]=="DPAD"):
                gamepad.directional_pad(direction=vg.DS4_DPAD_DIRECTIONS["DS4_BUTTON_"+msg[1:]])
            else:
                gamepad.press_button(button=vg.DS4_BUTTONS["DS4_BUTTON_" + msg[1:]])
        elif msg[0] == "R":
            if(msg[1:5]!="DPAD"):
                gamepad.release_button(button=vg.DS4_BUTTONS["DS4_BUTTON_" + msg[1:]])
        else:
            socket.sendto("received".encode('utf-8'), address)

        gamepad.update()
    elif not authenticated[0]:
        # Check for password
        logging.debug(f"Unauthenticated connection tried to connect from {address[0]}")

        if msg.decode('utf-8') == str(pin):
            print(f"{address[0]} Authenticated")
            authenticated = [True, address[0]]
            socket.sendto("authenticated".encode('utf-8'), address)
        else:
            socket.sendto("wrong password".encode('utf-8'), address)
    elif authenticated[1] != address:
        socket.sendto("another device".encode('utf-8'), address)