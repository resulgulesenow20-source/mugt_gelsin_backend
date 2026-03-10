import tkinter as tk
from tkinter import messagebox

# Global root reference to be set by main.py
root = None

def set_root(r):
    global root
    root = r

def clear_window():
    """Removes all widgets from the root window"""
    if root:
        for widget in root.winfo_children():
            widget.destroy()

# Ultra-Vibrant Renk Paleti (Süper Canlı ve Parlak)
NAV_BG = "#ffffff"         # Saf Beyaz
NAV_ACTIVE = "#6c5ce7"     # Elektrik Moru
NAV_FG = "#130f40"         # Derin İndigo (Siyah yerine daha canlı ve derin)
BRAND_COLOR = "#ff003c"    # Radikal Kırmızı
ACCENT_GREEN = "#1dd1a1"   # Tropikal Yeşil
ACCENT_ORANGE = "#ff9f43"  # Parlak Portakal
bg_main = "#f7f1e3"        # Fildişi Beyazı
CARD_BG = "#ffffff"        # Saf Beyaz Kartlar
TEXT_MAIN = "#130f40"      # Derin İndigo (Siyah yerine daha canlı)
TEXT_DIM = "#535c68"       # Çelik Grisi

def create_top_nav_bar(parent, shop_name, user_phone, active_page):
    """Görseldeki gibi üst navigasyon çubuğunu oluşturur"""
    from ui.dashboard import show_main_dashboard
    from ui.orders import show_orders_screen
    from ui.menu import show_menu_screen
    from ui.settings import show_settings_screen
    from ui.reports import show_reports_screen
    from ui.customer_service import show_customer_service_screen
    from ui.order_history import show_order_history_screen
    from ui.reviews import show_reviews_screen

    nav_frame = tk.Frame(parent, bg=NAV_BG, height=70)
    nav_frame.pack(side="top", fill="x")
    nav_frame.pack_propagate(False)

    # Sol taraftaki logo ve Restoran Id (veya isim)
    left_info = tk.Frame(nav_frame, bg=NAV_BG)
    left_info.pack(side="left", padx=20)
    
    tk.Label(left_info, text="📞", font=("Arial", 14), bg=NAV_BG).pack(side="left")
    tk.Label(left_info, text=f"Restoran Id : 6275", font=("Arial", 10, "bold"), bg=NAV_BG, fg="#636e72").pack(side="left", padx=5)

    # Orta Navigasyon Linkleri
    links_frame = tk.Frame(nav_frame, bg=NAV_BG)
    links_frame.pack(side="left", expand=True)

    def add_nav_link(icon, text, page_id, command):
        is_active = (active_page == page_id)
        btn_frame = tk.Frame(links_frame, bg=NAV_BG)
        btn_frame.pack(side="left", padx=15)
        
        icon_lbl = tk.Label(btn_frame, text=icon, font=("Arial", 14), bg=NAV_BG, fg=NAV_ACTIVE if is_active else NAV_FG, cursor="hand2")
        icon_lbl.pack()
        icon_lbl.bind("<Button-1>", lambda e: command())
        
        text_lbl = tk.Label(btn_frame, text=text, font=("Arial", 9, "bold" if is_active else "normal"), 
                           bg=NAV_BG, fg=NAV_ACTIVE if is_active else NAV_FG, cursor="hand2")
        text_lbl.pack()
        text_lbl.bind("<Button-1>", lambda e: command())
        
        if is_active:
            # Aktif sekme için alt çizgi (isteğe bağlı, görselde koyu renk yeterli)
            # tk.Frame(btn_frame, bg=NAV_ACTIVE, height=2).pack(fill="x", pady=(2,0))
            pass

    add_nav_link("🏠", "Ana Sayfa", "dashboard", lambda: show_main_dashboard(user_phone, shop_name))
    add_nav_link("📋", "Sipariş Ekranı", "orders", lambda: show_orders_screen(user_phone, shop_name))
    add_nav_link("🍴", "Menü", "menu", lambda: show_menu_screen(user_phone, shop_name))
    add_nav_link("🕰️", "Geçmiş Siparişler", "history", lambda: show_order_history_screen(user_phone, shop_name))
    add_nav_link("📊", "Raporlar", "reports", lambda: show_reports_screen(user_phone, shop_name))
    add_nav_link("🚚", "Kurye Gün Sonu", "courier", lambda: None) # placeholder

    # Sağ taraf (Profil, Ayarlar, Bildirimler)
    right_f = tk.Frame(nav_frame, bg=NAV_BG)
    right_f.pack(side="right", padx=20)
    
    # Bildirim İkonu
    tk.Label(right_f, text="🔔", font=("Arial", 14), bg=NAV_BG, fg=NAV_FG, cursor="hand2").pack(side="left", padx=10)
    
    # Ayarlar İkonu (Tıklanabilir)
    settings_btn = tk.Label(right_f, text="⚙️", font=("Arial", 14), bg=NAV_BG, fg=NAV_ACTIVE if active_page=="settings" else NAV_FG, cursor="hand2")
    settings_btn.pack(side="left", padx=10)
    settings_btn.bind("<Button-1>", lambda e: show_settings_screen(user_phone, shop_name))

    # Ayırıcı Çizgi
    tk.Frame(right_f, bg="#dfe6e9", width=1).pack(side="left", fill="y", padx=15, pady=15)

    # Profil Bilgisi
    profile_f = tk.Frame(right_f, bg=NAV_BG)
    profile_f.pack(side="left")
    
    tk.Label(profile_f, text=shop_name, font=("Arial", 9, "bold"), bg=NAV_BG, fg="#2d3436").pack(anchor="e")
    tk.Label(profile_f, text=user_phone, font=("Arial", 8), bg=NAV_BG, fg="#a4b0be").pack(anchor="e")
    
    # Profil İkonu / Avatar (Simüle)
    tk.Label(right_f, text="👤", font=("Arial", 18), bg="#f1f2f6", fg=NAV_ACTIVE, padx=8, pady=4).pack(side="left", padx=(10, 0))
    
    return nav_frame

def create_stat_card(parent, icon, title, value, icon_bg, click_command=None):
    card = tk.Frame(parent, bg="white", bd=1, relief="solid")
    if click_command:
        card.config(cursor="hand2")
        card.bind("<Button-1>", lambda e: click_command())
    card.pack(side="left", padx=(0, 15), ipadx=20, ipady=15, fill="x", expand=True)
    
    icon_label = tk.Label(card, text=icon, font=("Arial", 32), 
                         bg=icon_bg, fg="white", width=2, height=1)
    icon_label.pack(side="left", padx=10)
    if click_command:
        icon_label.bind("<Button-1>", lambda e: click_command())
    
    text_frame = tk.Frame(card, bg="white")
    text_frame.pack(side="left", fill="both", expand=True, padx=10)
    if click_command:
        text_frame.bind("<Button-1>", lambda e: click_command())
    
    lbl_title = tk.Label(text_frame, text=title, font=("Arial", 14), 
            bg="white", fg="#666")
    lbl_title.pack(anchor="w")
    if click_command:
        lbl_title.bind("<Button-1>", lambda e: click_command())
        
    lbl_value = tk.Label(text_frame, text=value, font=("Arial", 28, "bold"),
            bg="white", fg="#333")
    lbl_value.pack(anchor="w")
    if click_command:
        lbl_value.bind("<Button-1>", lambda e: click_command())
