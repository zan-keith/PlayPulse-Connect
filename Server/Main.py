"""
Author: @5_keith

PlayPulse Connect CLI

The program contains:
- Code that connects a virtual game controller using the functionality from the vgamepad Python module.
- Code that initializes a socket server on your PC at the preferred port.

"""

import argparse
import random
import socket
import vgamepad as vg
import logging
import threading
import keyboard

# ... (rest of your code)


parser = argparse.ArgumentParser(description="GamePadPortal")

parser.add_argument("--ip", metavar="ip", type=str, required=False,
                    help="Specify the IP address for the socket server.")
parser.add_argument("--port", metavar="port", type=int,required=False,
                    help="Specify the port for the socket server to run on.")
parser.add_argument("--pin", metavar="pin", type=int,required=False,
                    help="Specify the PIN authentication code. ( The code must be 4 digits ).")
parser.add_argument("--autokill", metavar="autokill", type=bool,required=False,
                    help="Automatically closes the server once the client presses disconnect.")

args = parser.parse_args()

arg_ip_address = args.ip
arg_port = args.port
arg_autokill = args.autokill if args.autokill else True
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
        exit()

stop_listener = False

# Define a function to listen for the key combination
def listener_thread():
    global stop_listener
    while True:
        if keyboard.is_pressed('ctrl+alt+c'):
            logging.warning("Terminating the server...")
            socket.close()
            stop_listener = True
            break

HOST_ADDRESS= arg_ip_address if arg_ip_address else get_host_ip()
PORT=arg_port if arg_port else 5000

if PORT<5000:
    logging.warning("Warning:\n If you are not using the default port numbers, use the higher port numbers to avoid unexpected behavior")
    if input(f"Do you want to continue with the port number {PORT} ? [y/N]").upper()!="Y":
        exit()

gamepad = vg.VX360Gamepad()

hostname = socket.gethostname()

socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
authenticated = [False, None]
address = None
try:
    socket.bind((HOST_ADDRESS, PORT))
    socket.settimeout(100)
except Exception as e:
    logging.error(e)
    exit()

print(f"SERVER IS RUNNING IN DEVICE {hostname} WITH IP {HOST_ADDRESS} SOCKET IN PORT {PORT}")
octets = HOST_ADDRESS.split(".")
fourth_octet = octets[3]

pin = arg_pin if (arg_pin and len(str(arg_pin))==4) else random.randint(1000, 9999)
print(f"PIN: {pin}{fourth_octet}")
print("Press Ctrl + Alt + C to exit the program")


# Start the listener thread
listener = threading.Thread(target=listener_thread)
listener.daemon = True
listener.start()

while True:

    if stop_listener:
        break
    try:
        msg, address = socket.recvfrom(1024)
    except OSError as e:
            if e.errno == 10038:
                # Socket is closed, break out of the loop
                break
            else:
                raise  # Re-raise other OSError exceptions

    if msg.decode("utf-8") == "supersecretpingmsg":
        socket.sendto("pong".encode('utf-8'), address)
    elif authenticated[0] and authenticated[1] == address[0]:

        msg = msg.decode("utf-8")
        if msg == "ENDCONN" and arg_autokill:
            logging.warning("Connection Ended By The Client")
            authenticated = [False, None]
            socket.close()
            exit()
        if msg[0:2] == "LJ":
            gamepad.left_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
        elif msg[0:2] == "RJ":
            gamepad.right_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
        elif msg[0:2] == "LT":
            gamepad.left_trigger_float(value_float=float(msg[2:]))
        elif msg[0:2] == "RT":
            gamepad.right_trigger_float(value_float=float(msg[2:]))
        elif msg[0] == "P":
            gamepad.press_button(button=vg.XUSB_BUTTON["XUSB_GAMEPAD_" + msg[1:]])
        elif msg[0] == "R":
            gamepad.release_button(button=vg.XUSB_BUTTON["XUSB_GAMEPAD_" + msg[1:]])
        else:
            socket.sendto("received".encode('utf-8'), address)
        gamepad.update()
    elif not authenticated[0]:
        # Check for password
        logging.debug(f"Unauthenticated connection tried to connect from {address[0]}")

        if msg.decode('utf-8') == str(pin):
            print(f"{address[0]} Authenticated")
            socket.sendto("authenticated".encode('utf-8'), address)
            authenticated = [True, address[0]]
        else:
            socket.sendto("wrong password".encode('utf-8'), address)
    elif authenticated[1] != address:
        socket.sendto("another device".encode('utf-8'), address)
listener.join()
