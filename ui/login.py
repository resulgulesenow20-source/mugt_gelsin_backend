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
                        btn_login.config(text="GİRİŞ YAP", state="normal", bg="#0284c7")
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
    # Increase window height slightly just in case, but rely on layout
    ui.utils.root.geometry("500x750")
    ui.utils.root.configure(bg="#0f172a") 

    global entry_phone, btn_login

    # Fixed: Removed fixed height, using pady for vertical centering
    # Using a canvas or just centering the frame
    main_frame = tk.Frame(ui.utils.root, bg="#0f172a")
    main_frame.place(relx=0.5, rely=0.5, anchor="center")

    container = tk.Frame(main_frame, bg="#1e293b", padx=30, pady=30, highlightthickness=1, highlightbackground="#334155")
    container.pack(expand=True, fill="both")

    # Logo - Compacted
    try:
        logo_path = os.path.join("static", "assets", "logo.png")
        if os.path.exists(logo_path):
            pil_img = Image.open(logo_path)
            # Resize image to fit nicely (e.g., 180x180 or 200x200)
            pil_img = pil_img.resize((200, 200), Image.Resampling.LANCZOS)
            logo_photo = ImageTk.PhotoImage(pil_img)
            logo_label = tk.Label(container, image=logo_photo, bg="#1e293b")
            logo_label.image = logo_photo # keep reference
            logo_label.pack(pady=(0, 10))
        else:
            tk.Label(container, text="📦", font=("Arial", 48), bg="#1e293b", fg="#38bdf8").pack(pady=(0, 5))
    except Exception as e:
        print(f"Logo load error: {e}")
        tk.Label(container, text="📦", font=("Arial", 48), bg="#1e293b", fg="#38bdf8").pack(pady=(0, 5))
    
    tk.Label(container, text="Mugt Gelsin", font=("Arial", 24, "bold"), fg="white", bg="#1e293b").pack()
    tk.Label(container, text="Restoran Yönetim Sistemi", font=("Arial", 10), fg="#94a3b8", bg="#1e293b").pack(pady=(0, 15))

    # Phone Entry Label
    tk.Label(container, text="TELEFON NUMARASI", font=("Arial", 9, "bold"), fg="#64748b", bg="#1e293b").pack(anchor="w", padx=5)

    # Phone Entry Wrapper
    entry_frame = tk.Frame(container, bg="#0f172a", bd=1, relief="flat", highlightthickness=2, highlightbackground="#334155")
    entry_frame.pack(pady=5, fill="x")
    
    entry_phone = tk.Entry(entry_frame, font=("Arial", 24), justify="center", bd=0, bg="#0f172a", fg="white", insertbackground="white")
    entry_phone.pack(pady=8, fill="x", padx=10)
    entry_phone.focus_set()
    
    # Bind Enter key
    entry_phone.bind("<Return>", lambda e: login())

    # Keypad Frame
    keypad_frame = tk.Frame(container, bg="#1e293b")
    keypad_frame.pack(pady=10)

    # Keypad buttons styling - slightly smaller to save space
    def create_key_btn(parent, text, cmd, bg="#334155", fg="white"):
        return tk.Button(parent, text=text, width=3, height=1, font=("Arial", 16, "bold"),
                         bg=bg, fg=fg, bd=0, activebackground="#475569", activeforeground="white",
                         cursor="hand2", command=cmd)

    buttons = [
        ('1', 0, 0), ('2', 0, 1), ('3', 0, 2),
        ('4', 1, 0), ('5', 1, 1), ('6', 1, 2),
        ('7', 2, 0), ('8', 2, 1), ('9', 2, 2),
        ('C', 3, 0), ('0', 3, 1), ('⌫', 3, 2)
    ]

    for (text, row, col) in buttons:
        if text == 'C':
            btn = create_key_btn(keypad_frame, text, clear_phone, bg="#ef4444")
        elif text == '⌫':
            btn = create_key_btn(keypad_frame, text, lambda: entry_phone.delete(len(entry_phone.get())-1))
        else:
            btn = create_key_btn(keypad_frame, text, lambda t=text: add_digit(t))
        
        btn.grid(row=row, column=col, padx=5, pady=5, sticky="nsew")

    # Login Button - Ensure it's very visible
    btn_login = tk.Button(container, text="GİRİŞ YAP", font=("Arial", 16, "bold"),
                          bg="#0284c7", fg="white", bd=0, pady=12,
                          activebackground="#0369a1", activeforeground="white",
                          cursor="hand2", command=login)
    btn_login.pack(fill="x", pady=(15, 0))

    # Footer
    tk.Label(container, text="Güvenli Giriş Paneli v1.2", font=("Arial", 8), fg="#475569", bg="#1e293b").pack(side="bottom", pady=(15, 0))
