
import os
from pathlib import Path
import subprocess
import sys
import threading

from tkinter import Tk, Canvas, Entry, Text, Button, PhotoImage,ttk

import webbrowser

import requests


OUTPUT_PATH = Path(__file__).parent
ASSETS_PATH = OUTPUT_PATH / Path(r"assets\frame1")


def relative_to_assets(path: str) -> Path:
    return ASSETS_PATH / Path(path)


window = Tk()

window.geometry("505x232")
window.configure(bg = "#FFFFFF")

def change_cursor(event):
    canvas.config(cursor="hand2") 
def restore_cursor(event):
    canvas.config(cursor="") 

def download_file():
    progress=0
    url = "https://github.com/nefarius/ViGEmBus/releases/download/v1.21.442.0/ViGEmBus_1.21.442_x64_x86_arm64.exe"
    response = requests.get(url, stream=True)
    
    total_size = int(response.headers.get("content-length", 0))
    block_size = 1024  # 1 Kibibyte
    
    with open("ViGEmBus_1.21.442_x64_x86_arm64.exe", "wb") as file:
        for data in response.iter_content(block_size):
            file.write(data)
            downloaded_size = len(data)
            progress+=downloaded_size
            canvas.itemconfigure(percent, text=str(int((progress/total_size)*100)))
    try:
        subprocess.run(['ViGEmBus_1.21.442_x64_x86_arm64.exe'], check=True)
    except:
        alert(False)
    finally:
        alert(True)
    print("Installer executed successfully.")
    print("Restart your pc to finish installing drivers and updates.")

def start_download():
    download_thread = threading.Thread(target=download_file)
    download_thread.start()

canvas = Canvas(
    window,
    bg = "#FFFFFF",
    height = 232,
    width = 505,
    bd = 0,
    highlightthickness = 0,
    relief = "ridge"
)

canvas.place(x = 0, y = 0)
image_image_1 = PhotoImage(
    file=relative_to_assets("image_1.png"))
image_1 = canvas.create_image(
    252.0,
    116.0,
    image=image_image_1
)


canvas.create_text(
    19.0,
    65.0,
    width=505-19,
    anchor="nw",
    text="We could not find the required ViGem drivers required for this application to work.",
    fill="#FFFFFF",
    font=("Rubik Regular", 13 * -1)
)

canvas.create_text(
    19.0,
    109.0,
    width=505-19,
    anchor="nw",
    text="Press proceed to download the installer for the driver software. Alternatively download it from the github repo ",
    fill="#FFFFFF",
    font=("Rubik Regular", 10 * -1)
)

canvas.create_text(
    19.0,
    158.0,
    anchor="nw",
    text="The Installation is quite straightforward. after the installation restart you pc to view the effects.",
    fill="#FFFFFF",
    font=("Rubik Regular", 10 * -1)
)


image_image_3 = PhotoImage(
    file=relative_to_assets("image_3.png"))
image_3 = canvas.create_image(
    367.0,
    47.0,
    image=image_image_3
)

percent=canvas.create_text(
        19.0+100,
        232-45,
        anchor="nw",
        text="0",
        fill="#ffffff",
        font=("Rubik Semibold", 10 * 1),
        state="hidden"
    )
def progress_bar():
    pad=19.0
    canvas.create_text(
        19.0,
        232-45,
        anchor="nw",
        text="Downloading",
        fill="#0ade11",
        font=("Rubik Semibold", 10 * 1)
    )
    canvas.itemconfig(percent, state="normal")
    canvas.create_text(
        pad+130,
        232-45,
        anchor="nw",
        text="%",
        fill="#a3f1a6",
        font=("Rubik Semibold", 10 * 1)
    )
    start_download()

img_4 = PhotoImage(
    file=relative_to_assets("image_4.png"))
proceed_btn = canvas.create_image(
    378.0,
    191.0+8,
    image=img_4
)



def on_proceed_press(event):
    canvas.itemconfigure(proceed_btn, state="hidden")
    progress_bar()
    

canvas.tag_bind(proceed_btn, "<Enter>", change_cursor)  
canvas.tag_bind(proceed_btn, "<Leave>", restore_cursor)
canvas.tag_bind(proceed_btn, "<Button-1>", on_proceed_press)


vigemlink=canvas.create_text(
    19.0,
    143.0,
    anchor="nw",
    text="https://github.com/nefarius/ViGEmBus/releases",
    fill="#347B77",
    font=("Rubik Regular", 10 * -1)
)
canvas.tag_bind(vigemlink, "<Enter>", change_cursor)  
canvas.tag_bind(vigemlink, "<Leave>", restore_cursor)
canvas.tag_bind(vigemlink, "<Button-1>", lambda event: webbrowser.open("https://github.com/nefarius/ViGEmBus/releases"))








canvas.create_text(
    57.0,
    15.0,
    anchor="nw",
    text="Playpulse Connect",
    fill="#FFFFFF",
    font=("Rubik Bold", 20 * -1)
)

image_image_2 = PhotoImage(
    file=relative_to_assets("image_2.png"))
image_2 = canvas.create_image(
    26.0,
    26.0,
    image=image_image_2
)

image_image_6 = PhotoImage(
    file=relative_to_assets("blue icon.png"))
image_6 = canvas.create_image(
    26.0,
    26.0,
    image=image_image_6
)


playpulselink=canvas.create_text(
    505/2,
    223.0,
    anchor="center",
    text="https://github.com/zan-keith/PlayPulse-Connect",
    fill="#00353C",
    font=("Rubik Medium", 8 * -1)
)
canvas.tag_bind(playpulselink, "<Enter>", change_cursor)  
canvas.tag_bind(playpulselink, "<Leave>", restore_cursor)
canvas.tag_bind(playpulselink, "<Button-1>", lambda event: webbrowser.open("https://github.com/zan-keith/PlayPulse-Connect"))


#------------ ALERT
img1 = PhotoImage(
    file=relative_to_assets("alert_bg.png"))
alertbg = canvas.create_image(
    252.0,
    116.0,
    image=img1,
    state="hidden"
    
)



restart_now_img = PhotoImage(
    file=relative_to_assets("restart_now.png"))
restart_now = canvas.create_image(
    140.0,
    166.0,
    state="hidden",
    image=restart_now_img    
)
canvas.tag_bind(restart_now, "<Enter>", change_cursor)  
canvas.tag_bind(restart_now, "<Leave>", restore_cursor)
canvas.tag_bind(restart_now, "<Button-1>", lambda event: sys.exit())

restart_later=canvas.create_text(
    335.0,
    161.0,
    anchor="nw",
    text="Restart Later",
    fill="#676767",
    state="hidden",
    font=("Rubik SemiBold", 12 * -1)
)
canvas.tag_bind(restart_later, "<Enter>", change_cursor)  
canvas.tag_bind(restart_later, "<Leave>", restore_cursor)

alerttxt=canvas.create_text(
    91.0,
    53.0,
    anchor="nw",
    text="Successfully Installed ViGem Drivers.",
    fill="#01A4C8",
    state="hidden",
    font=("Rubik Medium", 14 * -1)
)

alerttxt2=canvas.create_text(
    91.0,
    88.0,
    width=505-(88*2),
    anchor="nw",
    text="Restart your PC to view the effects.Reload Playpulse and Enjoy!",
    fill="#01A4C8",
    state="hidden",
    font=("Rubik Regular", 13 * -1)
)

def alert(success):
    
    if success:
        canvas.itemconfigure(alerttxt, state="normal")
        canvas.itemconfigure(alerttxt2, state="normal")
        canvas.itemconfigure(restart_now, state="normal")
        canvas.itemconfigure(restart_later, state="normal")
    else:
        canvas.itemconfigure(alerttxt, state="normal",text="Installation Unsuccessful",fill='red')
        canvas.itemconfigure(alerttxt2, state="normal",text="Try installing the drivers via the github repo if the issue persists.",fill='#3d0000')
        canvas.itemconfigure(restart_later, state="normal",text="Close")
        canvas.itemconfigure(restart_now, state="hidden")
    canvas.tag_bind(restart_later, "<Button-1>", lambda event: sys.exit())
    canvas.itemconfigure(alertbg, state="normal")

window.protocol("WM_DELETE_WINDOW", lambda : sys.exit())
window.resizable(False, False)
window.mainloop()