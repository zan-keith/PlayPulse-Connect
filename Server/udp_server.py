import random
import socket
import vgamepad as vg


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

ADDRESS,PORT=get_host_ip(),5000

gamepad = vg.VX360Gamepad()

hostname = socket.gethostname()

socket=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
authenticated=False

socket.bind((ADDRESS,PORT))

print(f"IP ADDRESS OF : {hostname} IS {ADDRESS} RUNNING SOCKET IN PORT {PORT}")
octets = ADDRESS.split(".")
fourth_octet = octets[3]

pin=random.randint(1000,9999)
print(f"PIN: {pin}{fourth_octet}")


while True:
    if authenticated:


        msg,address=socket.recvfrom(1024)
        msg=msg.decode("utf-8")
        if msg=="ENDCONN":
            print("ENDED")
            authenticated=False
            socket.close()
            exit()
        if msg[0:2]=="LJ":
            gamepad.left_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
            gamepad.update()
        elif msg[0:2]=="RJ":
            gamepad.right_joystick_float(x_value_float=float(msg[2:8]), y_value_float=float(msg[9:15]))
            gamepad.update()
        elif msg[0]=="P":
            gamepad.press_button(button=vg.XUSB_BUTTON["XUSB_GAMEPAD_"+msg[1:]])
            gamepad.update()
        elif msg[0]=="R":
            gamepad.release_button(button=vg.XUSB_BUTTON["XUSB_GAMEPAD_"+msg[1:]])
            gamepad.update()

        else:
            socket.sendto("received".encode('utf-8'), address)

    else:
        pwd, addr = socket.recvfrom(1024)
        print("- - - - unauthenticated connection",addr)


        if pwd.decode('utf-8')==str(pin):
            print(addr,"authenticated")
            socket.sendto("authenticated".encode('utf-8'), addr)
            authenticated=True
        else:
            socket.sendto("wrong password".encode('utf-8'), addr)
