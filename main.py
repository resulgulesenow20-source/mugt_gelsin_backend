# -*- coding: utf-8 -*-
import tkinter as tk
import ui.utils 
from ui.login import show_login
import data_manager_sqlite as data_manager
import threading
import subprocess
import os
import sys
import time


def start_backend():
    """Arka planda Flask sunucusunu başlatır"""
    try:
        # Backend dosyasının yolunu bul
        if getattr(sys, 'frozen', False):
            # Derlenmiş haldeyken (EXE)
            backend_script = os.path.join(sys._MEIPASS, "flask_backend.py") if hasattr(sys, '_MEIPASS') else "flask_backend.py"
        else:
            # Geliştirme aşamasında
            backend_script = "flask_backend.py"
        
        # Eğer EXE içindeyse farklı bir başlatma mantığı gerekebilir ama 
        # şimdilik subprocess ile python üzerinden (veya direkt import ile) deniyoruz.
        # En güvenli yol: Ayrı bir işlem olarak başlatmak
        subprocess.Popen([sys.executable, backend_script], 
                         creationflags=subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0)
        print(">>> Backend server started.")
    except Exception as e:
        print(f">>> Server start error: {e}")

def main():
    # Sunucuyu başlat
    threading.Thread(target=start_backend, daemon=True).start()
    time.sleep(2) # Sunucunun ayağa kalkması için kısa bir bekleme
    
    try:
        root = tk.Tk()
        ui.utils.set_root(root) # Initialize root in utils
        
        # Set Window Icon
        import os
        icon_path = os.path.join("static", "assets", "logo.ico")
        if os.path.exists(icon_path):
            root.iconbitmap(icon_path)
        
        # Check for auto-login
        saved_phone = data_manager.get_last_login()
        if saved_phone:
            is_setup = data_manager.get_setting("is_profile_setup", "0")
            shop_name = data_manager.get_setting("shop_name", "MUET Restoran")
            
            if is_setup == "1":
                from ui.dashboard import show_main_dashboard
                show_main_dashboard(saved_phone, shop_name)
            else:
                from ui.profile import show_shop_profile_form
                show_shop_profile_form(saved_phone)
        else:
            show_login() # Start with login screen
            
        root.mainloop()
    except Exception as e:
        import traceback
        with open("crash_report.log", "w") as f:
            f.write(f"Error: {e}\n")
            f.write(traceback.format_exc())
        raise e

if __name__ == "__main__":
    main()
