
## Export Instructions
- Download vgamepad ViGEmClient.dll from [here](https://github.com/yannbouteiller/vgamepad/tree/main/vgamepad/win/vigem/client/x64)

## Export Command
```
pyinstaller --noconfirm --onefile --windowed --icon "<abs_path>/lighticon.ico" --add-data <path to ViGEmClient dll> --add-data "<abs_path>/driver_fix.py" --add-data "<abs_path>/assets;assets/"  "<abs_path>/main.py"
```