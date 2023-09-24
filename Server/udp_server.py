import random
import socket
import vgamepad as vg
import logging


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


ADDRESS, PORT = get_host_ip(), 5000

gamepad = vg.VX360Gamepad()

hostname = socket.gethostname()

socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
authenticated = [False, None]
address = None
socket.bind((ADDRESS, PORT))

print(f"IP ADDRESS OF : {hostname} IS {ADDRESS} RUNNING SOCKET IN PORT {PORT}")
octets = ADDRESS.split(".")
fourth_octet = octets[3]

pin = random.randint(1000, 9999)
print(f"PIN: {pin}{fourth_octet}")

while True:
    msg, address = socket.recvfrom(1024)
    if msg.decode("utf-8") == "supersecretpingmsg":
        socket.sendto("pong".encode('utf-8'), address)
    elif authenticated[0] and authenticated[1] == address[0]:

        msg = msg.decode("utf-8")
        if msg == "ENDCONN":
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
        print(msg)
    elif not authenticated[0]:
        # Check for password
        logging.debug(f"- - - - unauthenticated connection {address[0]}")

        if msg.decode('utf-8') == str(pin):
            print(f"{address[0]} Authenticated")
            socket.sendto("authenticated".encode('utf-8'), address)
            authenticated = [True, address[0]]
        else:
            socket.sendto("wrong password".encode('utf-8'), address)
    elif authenticated[1] != address:
        socket.sendto("another device".encode('utf-8'), address)
