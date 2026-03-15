import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import os
import ui.utils 
from ui.utils import clear_window
import data_manager_sqlite as data_manager

entry_phone = None
btn_login = None

def login():
    try:
        from ui.profile import show_shop_profile_form
        from ui.dashboard import show_main_dashboard
        
        phone = entry_phone.get()
        
        if len(phone) >= 10 and phone.isdigit():
            # Button loading state
            btn_login.config(text="KONTROL EDİLİYOR...", state="disabled", bg="#64748b")
            
            def perform_login_check():
                try:
                    # Save login for persistence
                    data_manager.set_last_login(phone)
                    
                    # Check if shop profile exists (SQLite - fast)
                    is_setup = data_manager.get_setting("is_profile_setup", "0")
                    shop_name = data_manager.get_setting("shop_name", "Mugt Gelsin")
                    
                    if is_setup == "1":
                        # Backend üzerinden onay durumunu sorgula (Network - can be slow)
                        status = data_manager.check_shop_status(phone)
                        
                        def handle_result():
                            if status == "active":
                                show_main_dashboard(phone, shop_name)
                            else:
                                from ui.profile import show_waiting_approval_screen
                                show_waiting_approval_screen(phone, shop_name)
                        
                        ui.utils.root.after(0, handle_result)
                    else:
                        ui.utils.root.after(0, lambda: show_shop_profile_form(phone))
                except Exception as e:
                    def handle_error():
                        btn_login.config(text="GİRİŞ YAP", state="normal", bg="#FF6900")
                        messagebox.showerror("Hata", f"İşlem sırasında bir hata oluştu: {e}")
                    ui.utils.root.after(0, handle_error)

            import threading
            threading.Thread(target=perform_login_check, daemon=True).start()
            
        else:
            messagebox.showerror("Hata", "Lütfen geçerli bir telefon numarası giriniz (en az 10 hane).")
            entry_phone.delete(0, tk.END)
    except Exception as e:
        import traceback
        messagebox.showerror("Sistem Hatası", f"Giriş yapılamadı: {e}\n\n{traceback.format_exc()}")

def add_digit(digit):
    current = entry_phone.get()
    if len(current) < 11: 
        entry_phone.delete(0, tk.END)
        entry_phone.insert(0, current + str(digit))

def clear_phone():
    entry_phone.delete(0, tk.END)

def show_login():
    clear_window()
    ui.utils.root.title("Mugt Gelsin - Giriş Paneli")
    ui.utils.root.geometry("500x750")
    ui.utils.root.configure(bg=ui.utils.bg_main) 

    global entry_phone, btn_login

    main_frame = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_frame.place(relx=0.5, rely=0.5, anchor="center")

    container = tk.Frame(main_frame, bg="white", padx=40, pady=40, bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    container.pack(expand=True, fill="both")

    # Logo
    try:
        from PIL import Image, ImageTk
        import os
        logo_path = os.path.join("static", "assets", "logo.png")
        if os.path.exists(logo_path):
            pil_img = Image.open(logo_path)
            pil_img = pil_img.resize((150, 150), Image.Resampling.LANCZOS)
            logo_photo = ImageTk.PhotoImage(pil_img)
            logo_label = tk.Label(container, image=logo_photo, bg="white")
            logo_label.image = logo_photo
            logo_label.pack(pady=(0, 10))
        else:
            tk.Label(container, text="🏪", font=("Arial", 64), bg="white", fg=ui.utils.BRAND_COLOR).pack(pady=(0, 10))
    except Exception as e:
        print(f"Logo load error in login: {e}")
        tk.Label(container, text="🏪", font=("Arial", 64), bg="white", fg=ui.utils.BRAND_COLOR).pack(pady=(0, 10))
    
    tk.Label(container, text="MUGT GELSİN", font=("Inter", 24, "bold"), fg=ui.utils.BRAND_COLOR, bg="white").pack()
    tk.Label(container, text="Restoran Yönetim Sistemi", font=("Inter", 11), fg=ui.utils.TEXT_DIM, bg="white").pack(pady=(5, 20))

    # Phone Entry Label
    tk.Label(container, text="TELEFON NUMARASI", font=("Inter", 10, "bold"), fg=ui.utils.TEXT_MAIN, bg="white").pack(anchor="w", padx=5)

    # Phone Entry Wrapper
    entry_frame = tk.Frame(container, bg="white", bd=0, highlightthickness=2, highlightbackground=ui.utils.BORDER_COLOR)
    entry_frame.pack(pady=10, fill="x")
    
    entry_phone = tk.Entry(entry_frame, font=("Inter", 24, "bold"), justify="center", bd=0, bg="white", fg=ui.utils.TEXT_MAIN, insertbackground=ui.utils.BRAND_COLOR)
    entry_phone.pack(pady=10, fill="x", padx=10)
    entry_phone.focus_set()
    
    # Bind Enter key
    entry_phone.bind("<Return>", lambda e: login())

    # Keypad Frame
    keypad_frame = tk.Frame(container, bg="white")
    keypad_frame.pack(pady=15)

    def create_key_btn(parent, text, cmd, bg="#f8f9fa", fg=ui.utils.TEXT_MAIN):
        btn = tk.Button(parent, text=text, width=4, height=1, font=("Inter", 14, "bold"),
                         bg=bg, fg=fg, bd=0, activebackground="#e9ecef", activeforeground=fg,
                         cursor="hand2", command=cmd)
        return btn

    buttons = [
        ('1', 0, 0), ('2', 0, 1), ('3', 0, 2),
        ('4', 1, 0), ('5', 1, 1), ('6', 1, 2),
        ('7', 2, 0), ('8', 2, 1), ('9', 2, 2),
        ('C', 3, 0), ('0', 3, 1), ('⌫', 3, 2)
    ]

    for (text, row, col) in buttons:
        color_bg = "#f8f9fa"
        color_fg = ui.utils.TEXT_MAIN
        
        if text == 'C':
            color_bg = "#fff0f0"
            color_fg = "#e74c3c"
            btn = create_key_btn(keypad_frame, text, clear_phone, bg=color_bg, fg=color_fg)
        elif text == '⌫':
            btn = create_key_btn(keypad_frame, text, lambda: entry_phone.delete(len(entry_phone.get())-1))
        else:
            btn = create_key_btn(keypad_frame, text, lambda t=text: add_digit(t))
        
        btn.grid(row=row, column=col, padx=4, pady=4, sticky="nsew")

    # Login Button
    btn_login = tk.Button(container, text="GİRİŞ YAP", font=("Inter", 16, "bold"),
                          bg=ui.utils.BRAND_COLOR, fg="white", bd=0, pady=15,
                          activebackground="#E65F00", activeforeground="white",
                          cursor="hand2", command=login)
    btn_login.pack(fill="x", pady=(20, 0))
    ui.utils.add_hover_effect(btn_login, "#E65F00", ui.utils.BRAND_COLOR)

    # Footer
    tk.Label(container, text="Güvenli Giriş Paneli v2.0", font=("Inter", 9), fg=ui.utils.TEXT_DIM, bg="white").pack(side="bottom", pady=(20, 0))
