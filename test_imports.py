import sys
print(f"Python: {sys.version}")
try:
    import tkinter as tk
    print("Tkinter: OK")
    import requests
    print("Requests: OK")
    from PIL import Image, ImageTk
    print("Pillow: OK")
    import data_manager_sqlite as dm
    print("Data Manager: OK")
    print("All imports successful!")
except Exception as e:
    import traceback
    print(f"FAILED: {e}")
    traceback.print_exc()
