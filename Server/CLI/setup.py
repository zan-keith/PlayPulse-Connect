from cx_Freeze import setup, Executable

includefiles = ['spec/ViGEmClient.dll']

setup(
    name='Playpulse Desktop',
    version='1.0',
    description='Turn your smartphone into a game controller with this simple app.',
    author='zan-keith',
    options={'build_exe': {'include_files': includefiles}},
    executables=[Executable('main.py',
                            target_name="Playpulse Desktop.exe",
                            icon="darkicon.ico",
                            shortcut_name="Playpulse")]
)
