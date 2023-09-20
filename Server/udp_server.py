import random
import socket

ADDRESS,PORT="192.168.1.8",5000
socket=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
authenticated=False

socket.bind((ADDRESS,PORT))

pin=random.randint(1000,9999)
print("PIN: ",pin)

while True:
    if authenticated:


        msg,address=socket.recvfrom(1024)
        if msg.decode("utf-8")=="ENDCONN":
            print("ENDED")
            authenticated=False
            socket.close()
            exit()

        print(msg.decode("utf-8"),address)

        socket.sendto("received".encode('utf-8'),address)
    else:
        pwd, addr = socket.recvfrom(1024)
        print("- - - - unauthenticated connection",pwd)


        if pwd.decode('utf-8')==str(pin):
            print(addr,"authenticated")
            socket.sendto("authenticated".encode('utf-8'), addr)
            authenticated=True
        else:
            socket.sendto("wrong password".encode('utf-8'), addr)
