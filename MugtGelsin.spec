# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('ui', 'ui'), # Tüm UI klasörünü dahil et
        ('static', 'static'), # Logo ve ikonlar için
        ('data_manager_sqlite.py', '.'),
    ],
    hiddenimports=[
        'data_manager_sqlite',
        'ui.login',
        'ui.dashboard',
        'ui.orders',
        'ui.menu',
        'ui.profile',
        'ui.settings',
        'ui.reviews',
        'ui.utils',
        'requests',
        'PIL.ImageTk',
        'PIL.Image'
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='MugtGelsin',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True, # Hatayı görmek için geçici olarak True
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='static/assets/logo.ico' if os.path.exists('static/assets/logo.ico') else None
)
