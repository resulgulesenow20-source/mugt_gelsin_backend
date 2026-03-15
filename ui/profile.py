import tkinter as tk
import ui.utils
from ui.utils import clear_window
# from ui.dashboard import show_main_dashboard # Deferred import

def show_shop_profile_form(user_phone):
    from ui.dashboard import show_main_dashboard
    clear_window()
    ui.utils.root.title("Dükkan Profilini Oluştur")
    ui.utils.root.geometry("500x700")
    ui.utils.root.configure(bg="#f0f2f5") # Light gray background

    # Main Scrollable/Content Frame
    main_frame = tk.Frame(ui.utils.root, bg=ui.utils.bg_main, padx=30, pady=30)
    main_frame.pack(fill="both", expand=True)

    # Logo & Header Section
    header_container = tk.Frame(main_frame, bg=ui.utils.bg_main)
    header_container.pack(fill="x", pady=(0, 25))

    try:
        from PIL import Image, ImageTk
        import os
        logo_path = os.path.join("static", "assets", "logo.png")
        if os.path.exists(logo_path):
            pil_img = Image.open(logo_path)
            pil_img = pil_img.resize((100, 100), Image.Resampling.LANCZOS)
            logo_photo = ImageTk.PhotoImage(pil_img)
            logo_label = tk.Label(header_container, image=logo_photo, bg=ui.utils.bg_main)
            logo_label.image = logo_photo
            logo_label.pack(side="left", padx=(0, 20))
        else:
            tk.Label(header_container, text="🏪", font=("Arial", 40), bg=ui.utils.bg_main, fg=ui.utils.BRAND_COLOR).pack(side="left", padx=(0, 20))
    except Exception as e:
        print(f"Logo load error in profile: {e}")
        tk.Label(header_container, text="🏠", font=("Arial", 40), bg=ui.utils.bg_main, fg=ui.utils.BRAND_COLOR).pack(side="left", padx=(0, 20))

    title_frame = tk.Frame(header_container, bg=ui.utils.bg_main)
    title_frame.pack(side="left", fill="y")
    
    tk.Label(title_frame, text="Mugt Gelsin", font=("Inter", 24, "bold"), fg=ui.utils.BRAND_COLOR, bg=ui.utils.bg_main).pack(anchor="w")
    tk.Label(title_frame, text="Dükkan Profilini Oluştur", font=("Inter", 12), fg=ui.utils.TEXT_DIM, bg=ui.utils.bg_main).pack(anchor="w")

    # Helper function for form fields
    def create_field(parent, label_text, icon, placeholder):
        tk.Label(parent, text=label_text, font=("Inter", 10, "bold"), fg=ui.utils.TEXT_MAIN, bg=ui.utils.bg_main).pack(anchor="w", pady=(10, 5))
        
        entry_frame = tk.Frame(parent, bg="white", bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
        entry_frame.pack(fill="x", pady=(0, 5))
        
        tk.Label(entry_frame, text=icon, font=("Arial", 14), bg="white", fg=ui.utils.BRAND_COLOR, width=3).pack(side="left", padx=10)
        
        entry = tk.Entry(entry_frame, font=("Inter", 12), bd=0, bg="white", fg=ui.utils.TEXT_MAIN)
        entry.pack(side="left", fill="x", expand=True, ipady=12, padx=5)
        entry.insert(0, placeholder)
        
        # Placeholder behavior
        def on_focus_in(event):
            if entry.get() == placeholder:
                entry.delete(0, tk.END)
                entry.config(fg=ui.utils.TEXT_MAIN)
        def on_focus_out(event):
            if entry.get() == "":
                entry.insert(0, placeholder)
                entry.config(fg="#95a5a6")
        
        entry.config(fg="#95a5a6")
        entry.bind("<FocusIn>", on_focus_in)
        entry.bind("<FocusOut>", on_focus_out)
        
        return entry

    # Form Fields
    entry_shop_name = create_field(main_frame, "Dükkan Adı (Tabela Adı)", "🏠", "Örn: Resul Kebap Dünyası")
    entry_owner_name = create_field(main_frame, "İşletme Sahibi Ad Soyad", "👤", "Ad Soyad")
    entry_contact = create_field(main_frame, "İletişim Numarası", "📞", user_phone) # Pre-fill with login phone

    # Address Field (Multi-line)
    tk.Label(main_frame, text="Dükkan Açık Adresi", font=("Inter", 10, "bold"), fg=ui.utils.TEXT_MAIN, bg=ui.utils.bg_main).pack(anchor="w", pady=(10, 5))
    
    addr_frame = tk.Frame(main_frame, bg="white", bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    addr_frame.pack(fill="x")
    
    tk.Label(addr_frame, text="📍", font=("Arial", 14), bg="white", fg=ui.utils.BRAND_COLOR, width=3).pack(side="left", anchor="n", pady=15, padx=10)
    
    txt_address = tk.Text(addr_frame, font=("Inter", 12), bd=0, bg="white", height=3, fg=ui.utils.TEXT_MAIN)
    txt_address.pack(side="left", fill="x", expand=True, padx=5, pady=10)
    
    # Save Button
    def submit_profile():
        # Get form data (for future use)
        shop_name = entry_shop_name.get()
        owner_name = entry_owner_name.get()
        contact = entry_contact.get()
        address = txt_address.get("1.0", tk.END).strip()
        
        if shop_name and shop_name != "Örn: Mugt Gelsin Restoran":
            import data_manager_sqlite as data_manager
            data_manager.update_setting("shop_name", shop_name)
            data_manager.update_setting("owner_name", owner_name)
            data_manager.update_setting("phone", contact)
            data_manager.update_setting("address", address)
            data_manager.update_setting("is_profile_setup", "1")
            
            # Bulutla Senkronize Et (Firestore/Backend)
            data_manager.sync_profile_to_remote(user_phone)
            
            # Dashboard yerine Onay Bekleme ekranına git
            show_waiting_approval_screen(user_phone, shop_name)
        else:
            messagebox.showwarning("Uyarı", "Lütfen dükkan adını giriniz.")
    
    btn_save = tk.Button(main_frame, text="KAYDET VE ONAYA GÖNDER", font=("Inter", 12, "bold"), 
                         bg=ui.utils.BRAND_COLOR, fg="white", activebackground="#E65F00", activeforeground="white",
                         cursor="hand2", command=submit_profile, pady=15, bd=0)
    btn_save.pack(fill="x", pady=40)
    ui.utils.add_hover_effect(btn_save, "#E65F00", ui.utils.BRAND_COLOR)

def show_waiting_approval_screen(user_phone, shop_name):
    """Admin onayı bekleyen dükkanlar için bekleme ekranı"""
    import data_manager_sqlite as data_manager
    from ui.dashboard import show_main_dashboard
    
    clear_window()
    ui.utils.root.title("Onay Bekleniyor - Mugt Gelsin")
    ui.utils.root.geometry("550x650")
    ui.utils.root.configure(bg=ui.utils.bg_main)

    content_frame = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    content_frame.place(relx=0.5, rely=0.5, anchor="center")

    container = tk.Frame(content_frame, bg="white", padx=50, pady=50, bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    container.pack(expand=True, fill="both")

    # Logo or Icon
    try:
        from PIL import Image, ImageTk
        import os
        logo_path = os.path.join("static", "assets", "logo.png")
        if os.path.exists(logo_path):
            pil_img = Image.open(logo_path)
            pil_img = pil_img.resize((120, 120), Image.Resampling.LANCZOS)
            logo_photo = ImageTk.PhotoImage(pil_img)
            logo_label = tk.Label(container, image=logo_photo, bg="white")
            logo_label.image = logo_photo
            logo_label.pack(pady=(0, 20))
        else:
            tk.Label(container, text="🕒", font=("Arial", 60), bg="white", fg=ui.utils.BRAND_COLOR).pack(pady=(0, 20))
    except:
        tk.Label(container, text="🕒", font=("Arial", 60), bg="white", fg=ui.utils.BRAND_COLOR).pack(pady=(0, 20))

    tk.Label(container, text="Hesabınız İnceleniyor", font=("Inter", 22, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack()
    
    msg = f"Merhaba {shop_name},\n\nDükkan profiliniz başarıyla onaya gönderildi. Yönetici incelemesinden sonra tüm özellikler aktif edilecektir.\n\nLütfen beklemeye devam edin, onaylandığında bu ekran otomatik olarak kapanacaktır."
    tk.Label(container, text=msg, font=("Inter", 11), bg="white", fg=ui.utils.TEXT_DIM, wraplength=380, justify="center").pack(pady=30)

    status_badge = tk.Frame(container, bg=ui.utils.NAV_ACTIVE_LIGHT, padx=20, pady=10)
    status_badge.pack()
    tk.Label(status_badge, text="DURUM: ONAY BEKLİYOR", font=("Inter", 10, "bold"), bg=ui.utils.NAV_ACTIVE_LIGHT, fg=ui.utils.BRAND_COLOR).pack()

    def check_loop():
        if not hasattr(ui.utils, "root") or not ui.utils.root.winfo_exists(): return

        def run_check():
            try:
                status = data_manager.check_shop_status(user_phone)
                def process_status():
                    if status == "active":
                        messagebox.showinfo("Tebrikler! 🎉", "Hesabınız onaylandı! Uygulamaya giriş yapabilirsiniz.")
                        show_main_dashboard(user_phone, shop_name)
                    else:
                        ui.utils.root.after(5000, check_loop)
                ui.utils.root.after(0, process_status)
            except Exception as e:
                print(f"Check loop error: {e}")
                ui.utils.root.after(5000, check_loop)

        import threading
        threading.Thread(target=run_check, daemon=True).start()

    ui.utils.root.after(2000, check_loop)
    
    def perform_logout():
        """Oturumu kapatır ve kayıt durumunu sıfırlar ki kullanıcı tekrar kayıt olabilsin"""
        try:
            from tkinter import messagebox
            if messagebox.askyesno("Oturumu Kapat", "Tüm verileriniz temizlenecek ve tekrar kayıt olmanız gerekecek. Devam etmek istiyor musunuz?"):
                data_manager.clear_last_login()
                data_manager.update_setting("is_profile_setup", "0")
                ui.utils.root.quit()
        except Exception as e:
            print(f"Logout error: {e}")
            ui.utils.root.quit()

    btn_quit = tk.Button(container, text="OTURUMU KAPAT VE ÇIK", font=("Inter", 10, "bold"), 
                         bg="white", fg=ui.utils.ACCENT_RED, bd=0, cursor="hand2", 
                         command=perform_logout, pady=10)
    btn_quit.pack(side="bottom", pady=(40, 0))
    ui.utils.add_hover_effect(btn_quit, "#FFF0F0", "white")
