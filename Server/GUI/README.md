
## Export Instructions
- Download vgamepad ViGEmClient.dll from [here](https://github.com/yannbouteiller/vgamepad/tree/main/vgamepad/win/vigem/client/x64)

## Export Command
```
pyinstaller --noconfirm --onefile --windowed --icon "<abs_path>/lighticon.ico" --add-data <path to ViGEmClient dll> "<abs_path>/main.py"
```