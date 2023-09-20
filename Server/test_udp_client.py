import socket

ADDRESS,PORT="192.168.1.8",5000

client=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
nickname=input("nickname please")
client.sendto(f"{nickname} joined".encode('utf-8') , (ADDRESS,PORT))
msg=client.recvfrom(1024)[0].decode('utf-8')
print(msg)


if msg=="not authenticated":
    print('sending pwd')

    client.sendto("password".encode('utf-8'), (ADDRESS, PORT))
else:
    while True:
        clientmsg=input("")
        client.sendto(f"{nickname}:{clientmsg}".encode('utf-8'), (ADDRESS, PORT))


