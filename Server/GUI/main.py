"""
Author: @zan-keith

PlayPulse Connect GUI

The program contains:
- Code that connects a virtual game controller using the functionality from the vgamepad Python module.
- Code that initializes a socket server on your PC at the preferred port.
- Tkinter Gui Code
"""

import argparse
import random
import socket
import sys
import time
import requests

import logging
import threading
import keyboard

import webbrowser

from pathlib import Path
import subprocess


def fix_driver_issues():
    import driver_fix
    driver_fix.root.mainloop()



try:
    import vgamepad as vg
except Exception as e:
    fix_driver_issues()
    print(e)


from tkinter import Tk, Canvas, PhotoImage


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path(r"assets\frame0")


def relative_to_assets(path: str) -> Path:
    ## NOTE Change it to
    #return Path(r"assets\frame0") / Path(path) # for compiling using cx_freeze
    return ASSETS_PATH / Path(path) 
   


window = Tk()

window.geometry("675x232")
window.configure(bg = "#FFFFFF")
window.title(" PlayPulse Connect Desktop GUI")

p1 = PhotoImage(file = relative_to_assets('blue icon.png'))
window.iconphoto(False, p1)


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



# Function to listen for the key combination
HOST_ADDRESS= get_host_ip()
PORT=5000



gamepad = vg.VX360Gamepad()

hostname = socket.gethostname()

socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
authenticated = [False, None]
address = None
try:
    socket.bind((HOST_ADDRESS, PORT))
    socket.settimeout(200)
except Exception as e:
    logging.error(e)
    sys.exit()

print(f"SERVER IS RUNNING IN DEVICE {hostname} WITH IP {HOST_ADDRESS} SOCKET IN PORT {PORT}")
octets = HOST_ADDRESS.split(".")
fourth_octet = octets[3]

pin = random.randint(1000, 9999)
print(f"PIN: {pin}{fourth_octet}")



authenticated = [False, None]



# ------------------------------------------------------------------------------->

    









canvas = Canvas(
    window,
    bg = "#FFFFFF",
    height = 232,
    width = 675,
    bd = 0,
    highlightthickness = 0,
    relief = "ridge"
)

canvas.place(x = 0, y = 0)
image_image_1 = PhotoImage(
    file=relative_to_assets("image_1.png"))
image_1 = canvas.create_image(
    337.0,
    116.0,
    image=image_image_1
)

image_image_2 = PhotoImage(
    file=relative_to_assets("image_2.png"))
image_2 = canvas.create_image(
    564.0,
    116.0,
    image=image_image_2
)

canvas.create_text(
    60.0,
    12.0,
    anchor="nw",
    text="Playpulse",
    fill="#03fcf4",
    font=("Rubik Bold", 20 * -1)
)
canvas.create_text(
    166.0,
    12.0,
    anchor="nw",
    text="Connect",
    fill="#FFFFFF",
    font=("Rubik Light", 20 * -1)
)
image_image_3 = PhotoImage(
    file=relative_to_assets("image_3.png"))
image_3 = canvas.create_image(
    26.0,
    26.0,
    image=image_image_3
)

image_image_4 = PhotoImage(
    file=relative_to_assets("blue icon.png"))
image_4 = canvas.create_image(
    26.0,
    26.0,
    image=image_image_4
)

image_image_5 = PhotoImage(
    file=relative_to_assets("xbox-btn-inactive.png"))
image_5 = canvas.create_image(
    226.0,
    132.0,
    image=image_image_5
)

canvas.create_text(
    143.0,
    80.0,
    anchor="nw",
    text="Virtual Xbox 360",
    fill="#FFFFFF",
    font=("Rubik SemiBold", 20 * -1)
)

canvas.create_text(
    143.0,
    120.0,
    anchor="nw",
    text="Status :",
    fill="#A0A0A0",
    font=("Rubik Regular", 13 * -1)
)

canvas.create_text(
    463.0,
    137.0,
    anchor="nw",
    text="Local IP",
    fill="#A0A0A0",
    font=("Rubik Regular", 10 * -1)
)

canvas.create_text(
    463.0,
    178.0,
    anchor="nw",
    text="Port",
    fill="#A0A0A0",
    font=("Rubik Regular", 10 * -1)
)

canvas.create_text(
    463.0,
    153.0,
    anchor="nw",
    text=HOST_ADDRESS,
    fill="#00353C",
    font=("Rubik Medium", 12 * -1)
)
def change_cursor(event):
    canvas.config(cursor="hand2")  # Change cursor to a pointing hand when hovering
def restore_cursor(event):
    canvas.config(cursor="")  # Restore the default cursor when not hovering
def open_link(event):
    url = "https://github.com/zan-keith/PlayPulse-Connect"
    webbrowser.open(url)
text_item = canvas.create_text(
    215,
    215.0,
    anchor="center",
    text="https://github.com/zan-keith/PlayPulse-Connect",
    fill="#2a5b5e",

    font=("Rubik Medium", 11 * -1)
)
canvas.tag_bind(text_item, "<Enter>", change_cursor)  # Bind change_cursor to mouse enter event
canvas.tag_bind(text_item, "<Leave>", restore_cursor)
canvas.tag_bind(text_item, "<Button-1>", open_link)
def on_close_btn_press(e=None):
    
    socket.close()
    sys.exit()
def close_gracefully():
    socket.close()
    sys.exit()
button_image_1 = PhotoImage(
    file=relative_to_assets("button_1.png"),
)
running_btn = canvas.create_image(
    351.0,
    8.0,
    anchor='nw',
    image=button_image_1
)
canvas.tag_bind(running_btn, "<Enter>", change_cursor)  # Bind change_cursor to mouse enter event
canvas.tag_bind(running_btn, "<Leave>", restore_cursor)
canvas.tag_bind(running_btn, "<Button-1>", on_close_btn_press)

canvas.create_text(
    463.0,
    194.0,
    anchor="nw",
    text=PORT,
    fill="#043A3D",
    font=("Rubik Medium", 12 * -1)
)

canvas.create_text(
    143.0,
    150.0,
    anchor="nw",
    text="Device IP:",
    fill="#A0A0A0",
    font=("Rubik Regular", 13 * -1)
)

connection_label=canvas.create_text(
    194.06298828125,
    120.0,
    anchor="nw",
    text="Disconnected",
    fill="red",
    font=("Rubik Regular", 13 * -1)
)

connection_device_ip=canvas.create_text(
    208.06298828125,
    150.0,
    anchor="nw",
    text="Unknown",
    fill="#FFFFFF",
    font=("Rubik Regular", 13 * -1)
)

canvas.create_text(
    463.0,
    3.0,
    anchor="nw",
    text="Connection Info",
    fill="#B0B0B0",
    font=("Rubik Medium", 10 * -1)
)

canvas.create_text(
    463.0,
    56.0,
    anchor="nw",
    text=f"{pin}{octets[3]}",
    fill="#002020",
    font=("Rubik Medium", 40 * -1)
)

canvas.create_text(
    463.0,
    17.0,
    anchor="nw",
    text="Pass Code",
    fill="#FFFFFF",
    font=("Rubik SemiBold", 20 * -1)
)

image_image_6 = PhotoImage(
    file=relative_to_assets("image_6.png"))
image_6 = canvas.create_image(
    367.0,
    47.0,
    image=image_image_6
)


# ---------------------------------------------------------------->













def server_main():
    global authenticated,gamepad,canvas,connection_label,img
    while True:

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
            if msg == "ENDCONN":
                logging.warning("Connection Ended By The Client")
                authenticated = [False, None]
                canvas.itemconfig(connection_label, text="Disconnected",fill="red")
                canvas.itemconfig(connection_device_ip, text="None")
                img=PhotoImage(file=relative_to_assets("xbox-btn-inactive.png"))
                canvas.itemconfig(image_5,image=img)
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
                authenticated = [True, address[0]]
                
                canvas.itemconfig(connection_label, text="Connected",fill="#86BB17")
                canvas.itemconfig(connection_device_ip, text=str(address[0]))
                img=PhotoImage(file=relative_to_assets("xbox-btn-active.png"))
                canvas.itemconfig(image_5,image=img)
                
                socket.sendto("authenticated".encode('utf-8'), address)
            else:
                socket.sendto("wrong password".encode('utf-8'), address)
        elif authenticated[1] != address:
            socket.sendto("another device".encode('utf-8'), address)

server_thread = threading.Thread(target=server_main)
server_thread.start()


window.resizable(False, False)
window.protocol("WM_DELETE_WINDOW", close_gracefully)
window.mainloop()