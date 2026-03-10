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

    # Main Scrollable/Content Frame (using simple Frame for now)
    main_frame = tk.Frame(ui.utils.root, bg="#f0f2f5", padx=20, pady=20)
    main_frame.pack(fill="both", expand=True)

    # Header
    tk.Label(main_frame, text="Dükkan Profilini Oluştur", font=("Arial", 24, "bold"), fg="#1e3799", bg="#f0f2f5").pack(anchor="w")
    
    # Welcome & Instruction
    welcome_frame = tk.Frame(main_frame, bg="#f0f2f5", pady=10)
    welcome_frame.pack(fill="x", anchor="w")
    tk.Label(welcome_frame, text="Hoş Geldiniz! 🏪", font=("Arial", 18, "bold"), fg="#2c3e50", bg="#f0f2f5").pack(side="left")
    
    tk.Label(main_frame, text="Lütfen dükkan bilgilerinizi doldurup onaya gönderin.", font=("Arial", 12), fg="#7f8c8d", bg="#f0f2f5").pack(anchor="w", pady=(0, 20))

    # Helper function for form fields
    def create_field(parent, label_text, icon, placeholder):
        tk.Label(parent, text=label_text, font=("Arial", 14, "bold"), fg="#2c3e50", bg="#f0f2f5").pack(anchor="w", pady=(10, 5))
        
        entry_frame = tk.Frame(parent, bg="white", bd=1, relief="solid")
        entry_frame.pack(fill="x")
        
        tk.Label(entry_frame, text=icon, font=("Arial", 16), bg="white", fg="#7f8c8d", width=3).pack(side="left", padx=5)
        
        entry = tk.Entry(entry_frame, font=("Arial", 14), bd=0, bg="white")
        entry.pack(side="left", fill="x", expand=True, ipady=8, padx=5)
        entry.insert(0, placeholder)
        
        # Placeholder behavior
        def on_focus_in(event):
            if entry.get() == placeholder:
                entry.delete(0, tk.END)
                entry.config(fg="black")
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
    tk.Label(main_frame, text="Dükkan Açık Adresi", font=("Arial", 14, "bold"), fg="#2c3e50", bg="#f0f2f5").pack(anchor="w", pady=(10, 5))
    
    addr_frame = tk.Frame(main_frame, bg="white", bd=1, relief="solid")
    addr_frame.pack(fill="x")
    
    tk.Label(addr_frame, text="📍", font=("Arial", 16), bg="white", fg="#7f8c8d", width=3).pack(side="left", anchor="n", pady=10, padx=5)
    
    txt_address = tk.Text(addr_frame, font=("Arial", 14), bd=0, bg="white", height=4)
    txt_address.pack(side="left", fill="x", expand=True, padx=5, pady=5)
    
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
    
    btn_save = tk.Button(main_frame, text="KAYDET VE ONAYA GÖNDER", font=("Arial", 14, "bold"), 
                         bg="#0c2461", fg="white", activebackground="#1e3799", activeforeground="white",
                         cursor="hand2", command=submit_profile, pady=10)
    btn_save.pack(fill="x", pady=30)

def show_waiting_approval_screen(user_phone, shop_name):
    """Admin onayı bekleyen dükkanlar için bekleme ekranı"""
    import data_manager_sqlite as data_manager
    from ui.dashboard import show_main_dashboard
    
    clear_window()
    ui.utils.root.title("Onay Bekleniyor - Mugt Gelsin")
    ui.utils.root.geometry("500x600")
    ui.utils.root.configure(bg="white")

    content = tk.Frame(ui.utils.root, bg="white", padx=40, pady=60)
    content.pack(expand=True, fill="both")

    tk.Label(content, text="⏳", font=("Arial", 64), bg="white").pack(pady=20)
    tk.Label(content, text="Hesabınız İnceleniyor", font=("Arial", 22, "bold"), bg="white", fg="#2d3436").pack()
    
    msg = f"Merhaba {shop_name},\n\nBaşvurunuz başarıyla alındı. Yönetici onayından sonra tüm özellikler aktif edilecektir.\n\nLütfen bu ekranı kapatmayın, onaylandığında otomatik olarak açılacaktır."
    tk.Label(content, text=msg, font=("Arial", 11), bg="white", fg="#636e72", wraplength=400, justify="center").pack(pady=30)

    status_lbl = tk.Label(content, text="Durum: Onay Bekliyor...", font=("Arial", 10, "bold"), bg="#f1f2f6", fg="#6c5ce7", padx=20, pady=10)
    status_lbl.pack()

    def check_loop():
        # Sadece bekleme ekranındaysak devam et
        if not hasattr(ui.utils, "root") or not ui.utils.root.winfo_exists(): return

        def run_check():
            try:
                # Ağ isteği (Blocking - Arka planda çalışmalı)
                status = data_manager.check_shop_status(user_phone)
                
                def process_status():
                    if status == "active":
                        messagebox.showinfo("Tebrikler! 🎉", "Hesabınız onaylandı! Uygulamaya giriş yapabilirsiniz.")
                        show_main_dashboard(user_phone, shop_name)
                    else:
                        # 5 saniye sonra tekrar kontrol et
                        ui.utils.root.after(5000, check_loop)
                
                ui.utils.root.after(0, process_status)
            except Exception as e:
                print(f"Check loop error: {e}")
                ui.utils.root.after(5000, check_loop)

        import threading
        threading.Thread(target=run_check, daemon=True).start()

    # İlk kontrolü başlat
    ui.utils.root.after(2000, check_loop)
    
    tk.Button(content, text="ÇIKIŞ YAP", font=("Arial", 10, "bold"), bg="#dfe6e9", fg="#2d3436", 
              bd=0, padx=20, pady=8, command=lambda: ui.utils.root.quit()).pack(side="bottom", pady=20)
