try:
    print("Checking imports...")
    import tkinter as tk
    import ui.utils 
    from ui.login import show_login
    import data_manager_sqlite as data_manager
    print("Imports OK.")
except Exception as e:
    print(f"Import error: {e}")
    import traceback
    traceback.print_exc()
    exit(1)

try:
    print("Initializing root...")
    root = tk.Tk()
    ui.utils.set_root(root)
    print("Root initialized.")
    
    print("Checking last login...")
    saved_phone = data_manager.get_last_login()
    print(f"Last login: {saved_phone}")
    
    if saved_phone:
        print("Redirecting to dashboard (simulated)...")
        # from ui.dashboard import show_main_dashboard
        # shop_name = data_manager.get_setting("shop_name", "Dükkanım")
        # show_main_dashboard(saved_phone, shop_name)
    else:
        print("Calling show_login...")
        show_login()
        print("show_login called successfully.")
    
    print("App seems OK. Scheduled destroy in 3s.")
    root.after(3000, root.destroy)
    root.mainloop()
    print("Mainloop finished.")
except Exception as e:
    print(f"Runtime error: {e}")
    import traceback
    traceback.print_exc()
