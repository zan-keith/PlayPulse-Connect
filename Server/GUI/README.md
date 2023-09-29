
## Export Instructions
- Download vgamepad ViGEmClient.dll from [here](https://github.com/yannbouteiller/vgamepad/tree/main/vgamepad/win/vigem/client/x64)
- Move it to **spec/**

```
pip install cx_Freeze
```
- Change line 50 in main.py
- Change line 22 in driver_fix.py

## Export Command
For installer :
```
python setup.py bdist_msi
```

or

For direct install
```
python setup.py build
```