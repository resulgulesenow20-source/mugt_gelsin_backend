import tkinter as tk
from tkinter import messagebox
import ui.utils
from ui.utils import clear_window, create_top_nav_bar
import data_manager_sqlite as data_manager
from tkinter import filedialog
from PIL import Image, ImageTk
import os

def show_settings_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Ayarlar - {shop_name}")
    ui.utils.root.geometry("1100x850")
    ui.utils.root.configure(bg=ui.utils.bg_main)
    
    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "settings")
    
    # Ana İçerik Alanı (Kaydırılabilir)
    main_container = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_container.pack(fill="both", expand=True)
    
    canvas = tk.Canvas(main_container, bg=ui.utils.bg_main, highlightthickness=0)
    canvas.pack(side="left", fill="both", expand=True, padx=40, pady=20)
    
    scrollbar = tk.Scrollbar(main_container, orient="vertical", command=canvas.yview)
    scrollbar.pack(side="right", fill="y")
    canvas.configure(yscrollcommand=scrollbar.set)
    
    content = tk.Frame(canvas, bg=ui.utils.bg_main)
    canvas.create_window((0,0), window=content, anchor="nw")
    
    def on_configure(event):
        canvas.configure(scrollregion=canvas.bbox("all"))
        canvas.itemconfig(1, width=event.width)
    canvas.bind('<Configure>', on_configure)

    # Üst Başlık ve Master Switch Alanı
    header_frame = tk.Frame(content, bg=ui.utils.bg_main)
    header_frame.pack(fill="x", pady=(0, 25))
    
    tk.Label(header_frame, text="⚙️ Mağaza Yönetim Merkezi", font=("Arial", 26, "bold"), bg=ui.utils.bg_main, fg=ui.utils.TEXT_MAIN).pack(side="left")
    
    # MASTER SWITCH (Restoran Durumu)
    def toggle_master():
        current = data_manager.get_setting("shop_status", "AÇIK")
        new_val = "KAPALI" if current == "AÇIK" else "AÇIK"
        data_manager.update_setting("shop_status", new_val)
        data_manager.sync_profile_to_remote()
        show_settings_screen(user_phone, shop_name)

    shop_status = data_manager.get_setting("shop_status", "AÇIK")
    ms_bg = ui.utils.ACCENT_GREEN if shop_status == "AÇIK" else ui.utils.TEXT_DIM
    ms_btn = tk.Button(header_frame, text=f"RESTORAN {shop_status}", font=("Arial", 12, "bold"), 
                      bg=ms_bg, fg="white", bd=0, padx=25, pady=10, cursor="hand2", command=toggle_master)
    ms_btn.pack(side="right")

    def create_section(parent, title, icon=""):
        frame = tk.Frame(parent, bg=ui.utils.CARD_BG, padx=30, pady=30, bd=0)
        frame.pack(fill="x", pady=12)
        
        title_frame = tk.Frame(frame, bg=ui.utils.CARD_BG)
        title_frame.pack(fill="x", pady=(0, 20))
        
        tk.Label(title_frame, text=f"{icon} {title}", font=("Arial", 16, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.NAV_ACTIVE).pack(side="left")
        tk.Frame(frame, bg=ui.utils.bg_main, height=2).pack(fill="x", pady=(0, 20))
        return frame

    def create_input(parent, label, value, help_text=""):
        f = tk.Frame(parent, bg=ui.utils.CARD_BG)
        f.pack(fill="x", pady=10)
        
        lbl_f = tk.Frame(f, bg=ui.utils.CARD_BG)
        lbl_f.pack(fill="x")
        tk.Label(lbl_f, text=label, font=("Arial", 10, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_MAIN).pack(side="left")
        if help_text:
            tk.Label(lbl_f, text=f"({help_text})", font=("Arial", 9), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(side="left", padx=10)
            
        e = tk.Entry(f, font=("Arial", 12), bg=ui.utils.bg_main, fg=ui.utils.TEXT_MAIN, bd=0, relief="flat", 
                     highlightthickness=1, highlightbackground="#ced6e0", highlightcolor=ui.utils.NAV_ACTIVE, insertbackground="black")
        e.pack(fill="x", ipady=10, pady=5)
        e.insert(0, value)
        return e

    # 1. KURUMSAL PROFİL (Eski Genel Bilgiler)
    gen_sec = create_section(content, "Kurumsal Profil", "🏢")
    
    # Doğrulanmış Rozeti
    badge_f = tk.Frame(gen_sec, bg="#e3fcef", padx=10, pady=5)
    badge_f.pack(anchor="w", pady=(0, 20))
    tk.Label(badge_f, text="✅ DOĞRULANMIŞ İŞLETME", font=("Arial", 9, "bold"), bg="#e3fcef", fg=ui.utils.ACCENT_GREEN).pack()

    # Grid düzeni için ana frame
    grid_f = tk.Frame(gen_sec, bg=ui.utils.CARD_BG)
    grid_f.pack(fill="x")
    
    # Sütun 1
    col1 = tk.Frame(grid_f, bg=ui.utils.CARD_BG)
    col1.pack(side="left", fill="x", expand=True, padx=(0, 10))
    
    # Sütun 2
    col2 = tk.Frame(grid_f, bg=ui.utils.CARD_BG)
    col2.pack(side="left", fill="x", expand=True, padx=(10, 0))

    # Alanları dağıtıyoruz
    e_shop_id = create_input(col1, "Mağaza Kimliği (ID)", data_manager.get_setting("shop_id", "MGT-7829-X"), "Değiştirilemez")
    e_shop_id.config(state="readonly")
    
    e_shop_name = create_input(col2, "Mağaza Adı", data_manager.get_setting("shop_name", shop_name), "Görünen isim")
    
    e_category = create_input(col1, "Mutfak Kategorisi", data_manager.get_setting("shop_category", "Hızlı Yemek / Restoran"), "Örn: Kebap, Pizza")
    e_phone = create_input(col2, "Resmi İletişim Hattı", data_manager.get_setting("phone", user_phone))
    
    e_instagram = create_input(col1, "Instagram Kullanıcı Adı", data_manager.get_setting("shop_instagram", "@mugtgelsin"), "Örn: @magaza_adi")
    e_website = create_input(col2, "Web Sitesi / Link", data_manager.get_setting("shop_website", "www.mugtgelsin.com"))

    # Adres tam genişlikte olsun
    e_address = create_input(gen_sec, "Tam Mağaza Adresi", data_manager.get_setting("address", ""), "Kurye ve müşteriler için açık adres")

    # 2. OPERASYON AYARLARI
    ops_sec = create_section(content, "Operasyon ve Mutfak", "🛠️")
    
    # Otomatik Onay
    def toggle_auto():
        current = data_manager.get_setting("auto_confirm", "AÇIK")
        data_manager.update_setting("auto_confirm", "KAPALI" if current == "AÇIK" else "AÇIK")
        show_settings_screen(user_phone, shop_name)
    
    auto_val = data_manager.get_setting("auto_confirm", "AÇIK")
    f_auto = tk.Frame(ops_sec, bg=ui.utils.CARD_BG)
    f_auto.pack(fill="x", pady=10)
    tk.Label(f_auto, text="Yeni Siparişleri Otomatik Onayla", font=("Arial", 11, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_MAIN).pack(side="left")
    tk.Button(f_auto, text=auto_val, bg=ui.utils.NAV_ACTIVE if auto_val=="AÇIK" else ui.utils.TEXT_DIM, 
              fg="white", font=("Arial", 9, "bold"), bd=0, padx=15, pady=5, command=toggle_auto).pack(side="right")

    e_min_order = create_input(ops_sec, "Minimum Sipariş Tutarı", data_manager.get_setting("min_order_amount", "50.0"), "₺ cinsinden")
    
    # Teslimat Süresi Dropdown simülasyonu
    def set_delivery_time(val):
        data_manager.update_setting("avg_delivery_time", val)
        show_settings_screen(user_phone, shop_name)

    f_time = tk.Frame(ops_sec, bg=ui.utils.CARD_BG)
    f_time.pack(fill="x", pady=10)
    tk.Label(f_time, text="Ortalama Hazırlama Süresi", font=("Arial", 11, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_MAIN).pack(side="left")
    t_val = data_manager.get_setting("avg_delivery_time", "20 dk")
    t_btn_f = tk.Frame(f_time, bg=ui.utils.CARD_BG)
    t_btn_f.pack(side="right")
    for t in ["15 dk", "30 dk", "45 dk"]:
        btn_c = ui.utils.ACCENT_ORANGE if t_val == t else "#f1f2f6"
        btn_fg = "white" if t_val == t else ui.utils.TEXT_DIM
        tk.Button(t_btn_f, text=t, bg=btn_c, fg=btn_fg, bd=0, padx=10, pady=3, font=("Arial", 9, "bold"),
                  command=lambda v=t: set_delivery_time(v)).pack(side="left", padx=2)

    # 3. MARKA VE LOGO
    brand_sec = create_section(content, "Marka ve Görünüm", "🖼️")
    logo_container = tk.Frame(brand_sec, bg=ui.utils.CARD_BG)
    logo_container.pack(fill="x")
    
    lbl_logo_preview = tk.Label(logo_container, text="MAĞAZA LOGOSU", font=("Arial", 9, "bold"), bg=ui.utils.bg_main, width=15, height=5, fg=ui.utils.TEXT_DIM)
    lbl_logo_preview.pack(side="left", padx=(0, 20))
    
    current_logo_path = tk.StringVar(value=data_manager.get_setting("shop_logo_path", ""))
    def pick_logo():
        path = filedialog.askopenfilename(filetypes=[("Resim Dosyaları", "*.png *.jpg *.jpeg")])
        if path:
            current_logo_path.set(path)
            messagebox.showinfo("Başarılı", "Logo seçildi, kaydetmeyi unutmayın!")

    tk.Button(logo_container, text="📁 Logoyu Değiştir", command=pick_logo, bg=ui.utils.ACCENT_GREEN, fg="white", font=("Arial", 10, "bold"), bd=0, padx=20, pady=10, cursor="hand2").pack(side="left")

    # KAYDET BUTONU
    def save_all():
        data_manager.update_setting("shop_name", e_shop_name.get())
        data_manager.update_setting("phone", e_phone.get())
        data_manager.update_setting("address", e_address.get())
        data_manager.update_setting("shop_category", e_category.get())
        data_manager.update_setting("shop_instagram", e_instagram.get())
        data_manager.update_setting("shop_website", e_website.get())
        data_manager.update_setting("shop_logo_path", current_logo_path.get())
        data_manager.update_setting("min_order_amount", e_min_order.get())
        data_manager.sync_profile_to_remote(user_phone)
        messagebox.showinfo("Başarılı ✨", "Kurumsal profiliniz ve mağaza ayarlarınız güncellendi! 🚀")
        show_settings_screen(e_phone.get(), e_shop_name.get())

    # TEHLİKELİ BÖLGE (Hesap Silme)
    tk.Frame(content, bg="#dfe6e9", height=2).pack(fill="x", pady=30)
    
    danger_sec = tk.Frame(content, bg=ui.utils.bg_main)
    danger_sec.pack(fill="x", pady=10)
    
    tk.Label(danger_sec, text="🚩 TEHLİKELİ BÖLGE", font=("Arial", 12, "bold"), bg=ui.utils.bg_main, fg="#d63031").pack(anchor="w")
    tk.Label(danger_sec, text="Hesabınızı silmek tüm verilerinizi (menü, siparişler, ayarlar) hem bu cihazdan hem de buluttan kalıcı olarak kaldıracaktır.", 
             font=("Arial", 9), bg=ui.utils.bg_main, fg=ui.utils.TEXT_DIM).pack(anchor="w", pady=5)

    def confirm_delete():
        # Basit bir onay iletişim kutusu yerine özel bir güvenlik sorusu
        confirm_modal = tk.Toplevel(ui.utils.root)
        confirm_modal.title("⚠️ DİKKAT: Hesabı Sil")
        confirm_modal.geometry("400x250")
        confirm_modal.configure(bg="white")
        confirm_modal.transient(ui.utils.root)
        confirm_modal.grab_set()

        tk.Label(confirm_modal, text="Verileri silmek üzeresiniz!", font=("Arial", 12, "bold"), bg="white", fg="#d63031").pack(pady=20)
        tk.Label(confirm_modal, text=f"Onaylamak için '{shop_name}' yazın:", bg="white", fg=ui.utils.TEXT_MAIN).pack()
        
        e_confirm = tk.Entry(confirm_modal, font=("Arial", 12), justify="center", bd=1, relief="solid")
        e_confirm.pack(pady=10, ipady=5, padx=40, fill="x")
        e_confirm.focus_set()

        def final_delete():
            if e_confirm.get() == shop_name:
                if data_manager.delete_account(user_phone):
                    messagebox.showinfo("Hoşçakalın 👋", "Hesabınız ve tüm verileriniz başarıyla silindi.")
                    from ui.login import show_login
                    show_login()
                else:
                    messagebox.showerror("Hata", "Silme işlemi sırasında bir sorun oluştu.")
            else:
                messagebox.showwarning("Hata", "Mağaza adını yanlış girdiniz.")
            confirm_modal.destroy()

        tk.Button(confirm_modal, text="💥 KALICI OLARAK SİL", command=final_delete, bg="#d63031", fg="white", 
                  font=("Arial", 10, "bold"), pady=10).pack(pady=10, fill="x", padx=40)

    tk.Button(danger_sec, text="❌ HESABIMI VE TÜM VERİLERİ SİL", command=confirm_delete, 
              bg="white", fg="#d63031", font=("Arial", 10, "bold"), bd=1, relief="solid", padx=20, pady=8, cursor="hand2").pack(anchor="w", pady=10)

    save_btn = tk.Button(content, text="🚀 TÜM DEĞİŞİKLİKLERİ KAYDET", command=save_all, bg=ui.utils.BRAND_COLOR, fg="white", font=("Arial", 16, "bold"), bd=0, pady=20, cursor="hand2")
    save_btn.pack(fill="x", pady=(30, 50))

    # 4. GÜVENLİK VE ÇIKIŞ
    danger_sec = create_section(content, "Güvenlik ve Oturum", "🔒")
    def logout():
        if messagebox.askyesno("Çıkış", "Mağazadan çıkış yapmak istediğinize emin misiniz?"):
            data_manager.clear_last_login()
            from ui.login import show_login
            show_login()

    tk.Button(danger_sec, text="🚪 Oturumu Güvenli Kapat", command=logout, bg=ui.utils.CARD_BG, fg=ui.utils.BRAND_COLOR, font=("Arial", 11, "bold"), bd=1, relief="solid", padx=25, pady=10, cursor="hand2").pack(side="left", padx=5)
    tk.Button(danger_sec, text="🗑️ Tüm Verileri Sıfırla", command=lambda: messagebox.showwarning("Dur!", "Bu işlem geri alınamaz ve yakında eklenecek."), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM, font=("Arial", 11, "bold"), bd=1, relief="solid", padx=25, pady=10, cursor="hand2").pack(side="left", padx=5)

