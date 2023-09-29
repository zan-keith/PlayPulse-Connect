from cx_Freeze import setup, Executable, bdist_msi

includefiles = ['spec/ViGEmClient.dll', 'driver_fix.py', ('assets/')]

#Literally copied from https://stackoverflow.com/questions/15734703/use-cx-freeze-to-create-an-msi-that-adds-a-shortcut-to-the-desktop
shortcut_table = [
    ("StartMenuFolder",        # Shortcut
     "DesktopFolder",          # Directory_
     "Playpulse Link",           # Name that will be show on the link
     "TARGETDIR",              # Component_
     "[TARGETDIR]Playpulse Desktop.exe",# Target exe to exexute
     None,                     # Arguments
     None,                     # Description
     None,                     # Hotkey
     None,                     # Icon
     None,                     # IconIndex
     None,                     # ShowCmd
     'TARGETDIR'               # WkDir
     )
    ]
# Now create the table dictionary
msi_data = {"Shortcut": shortcut_table}

# Change some default MSI options and specify the use of the above defined tables
bdist_msi_options = {'data': msi_data}

options = {
    "bdist_msi": bdist_msi_options,
    'build_exe': {
                'include_files': includefiles
                }
}

setup(
    name='Playpulse Desktop GUI',
    version='1.0',
    description='Turn your smartphone into a game controller with this simple app.',
    author='zan-keith',
    executables=[Executable('main.py',
                            target_name="Playpulse Desktop.exe",
                            icon="lighticon.ico",
                            base="Win32GUI",
                            )],
    options=options,

)
