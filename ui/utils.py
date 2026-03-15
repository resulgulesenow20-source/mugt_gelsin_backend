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

# Trendyol inspired Premium Renk Paleti (Modern & Enerjik)
NAV_BG = "#ffffff"         # Saf Beyaz
NAV_ACTIVE = "#F27A1A"     # Trendyol Turuncusu (Ana Renk)
NAV_ACTIVE_LIGHT = "#FFF0E5" # Aktif arka plan (Çok Açık Turuncu)
NAV_FG = "#333333"         # Koyu Gri Metin
BRAND_COLOR = "#F27A1A"    # Ana Marka Rengi
ACCENT_GREEN = "#27AE60"   # Başarı Yeşili
ACCENT_RED = "#E64133"     # Hata/Çıkış Kırmızısı
ACCENT_ORANGE = "#FF9500"  # Yardımcı Turuncu
bg_main = "#F6F6F6"        # Modern Çok Açık Gri Arka Plan
CARD_BG = "#ffffff"        # Kart Arka Planı
TEXT_MAIN = "#333333"      # Ana Metin
TEXT_DIM = "#666666"       # İkincil Metin
BORDER_COLOR = "#EBEBEB"   # İnce Kenarlık

def draw_rounded_rect(canvas, x1, y1, x2, y2, radius=10, **kwargs):
    """Canvas üzerinde yuvarlatılmış dikdörtgen çizer"""
    points = [x1+radius, y1,
              x1+radius, y1, x2-radius, y1, x2-radius, y1, x2, y1,
              x2, y1+radius, x2, y1+radius, x2, y2-radius, x2, y2-radius, x2, y2,
              x2-radius, y2, x2-radius, y2, x1+radius, y2, x1+radius, y2, x1, y2,
              x1, y2-radius, x1, y2-radius, x1, y1+radius, x1, y1+radius, x1, y1]
    return canvas.create_polygon(points, **kwargs, smooth=True)

def add_hover_effect(widget, hover_bg, normal_bg, cursor="hand2"):
    """Widget üzerine gelindiğinde renk değişimi sağlar"""
    widget.bind("<Enter>", lambda e: widget.config(bg=hover_bg))
    widget.bind("<Leave>", lambda e: widget.config(bg=normal_bg))
    widget.config(cursor=cursor)

def create_sidebar(parent, shop_name, user_phone, active_page):
    """Modern Sidebar - Trendyol-inspired premium look (Left Side)"""
    sidebar_frame = tk.Frame(parent, bg="white", width=260, highlightthickness=1, highlightbackground=BORDER_COLOR)
    sidebar_frame.pack(side="left", fill="y")
    sidebar_frame.pack_propagate(False)

    # Logo Area
    logo_container = tk.Frame(sidebar_frame, bg="white", pady=30)
    logo_container.pack(fill="x")
    
    try:
        from PIL import Image, ImageTk
        import os
        logo_path = os.path.join("static", "assets", "logo.png")
        if os.path.exists(logo_path):
            pil_img = Image.open(logo_path)
            pil_img = pil_img.resize((60, 60), Image.Resampling.LANCZOS)
            logo_photo = ImageTk.PhotoImage(pil_img)
            logo_lbl = tk.Label(logo_container, image=logo_photo, bg="white")
            logo_lbl.image = logo_photo
            logo_lbl.pack()
        else:
            tk.Label(logo_container, text="MUGT 📦", font=("Inter", 16, "bold"), fg=BRAND_COLOR, bg="white").pack()
    except:
        tk.Label(logo_container, text="MUGT 📦", font=("Inter", 16, "bold"), fg=BRAND_COLOR, bg="white").pack()

    tk.Label(sidebar_frame, text=shop_name[:20], font=("Inter", 10, "bold"), fg=TEXT_DIM, bg="white").pack(pady=(0, 20))

    # Nav Items
    nav_container = tk.Frame(sidebar_frame, bg="white")
    nav_container.pack(fill="both", expand=True, padx=10)

    def add_nav_item(icon, text, page_id, command):
        is_active = (active_page == page_id)
        bg_col = NAV_ACTIVE_LIGHT if is_active else "white"
        fg_col = NAV_ACTIVE if is_active else TEXT_MAIN
        
        btn_frame = tk.Frame(nav_container, bg=bg_col, pady=2)
        btn_frame.pack(fill="x", pady=2)
        
        if is_active:
            indicator = tk.Frame(btn_frame, bg=NAV_ACTIVE, width=4)
            indicator.pack(side="left", fill="y")
        
        btn = tk.Button(btn_frame, text=f"  {icon}  {text}", font=("Inter", 10, "bold" if is_active else "normal"),
                         bg=bg_col, fg=fg_col, bd=0, anchor="w", cursor="hand2", 
                         padx=15, pady=12, activebackground=NAV_ACTIVE_LIGHT, activeforeground=NAV_ACTIVE,
                         command=command)
        btn.pack(side="left", fill="x", expand=True)
        
        if not is_active:
            def on_e(e): 
                btn_frame.config(bg="#f8f9fa")
                btn.config(bg="#f8f9fa")
            def on_l(e): 
                btn_frame.config(bg="white")
                btn.config(bg="white")
            btn.bind("<Enter>", on_e)
            btn.bind("<Leave>", on_l)

    # Dynamic Imports
    from ui.dashboard import show_main_dashboard
    from ui.orders import show_orders_screen
    from ui.menu import show_menu_screen
    from ui.reports import show_reports_screen
    from ui.settings import show_settings_screen
    from ui.courier import show_courier_screen
    from ui.customer_service import show_customer_service_screen

    add_nav_item("🏠", "Ana Sayfa", "dashboard", lambda: show_main_dashboard(user_phone, shop_name))
    add_nav_item("📋", "Siparişler", "orders", lambda: show_orders_screen(user_phone, shop_name))
    add_nav_item("🍔", "Menü Yönetimi", "menu", lambda: show_menu_screen(user_phone, shop_name))
    add_nav_item("🛵", "Kurye Yönetimi", "courier", lambda: show_courier_screen(user_phone, shop_name))
    add_nav_item("📊", "Raporlar", "reports", lambda: show_reports_screen(user_phone, shop_name))
    add_nav_item("💬", "Canlı Destek", "support", lambda: show_customer_service_screen(user_phone, shop_name))
    add_nav_item("⚙️", "Ayarlar", "settings", lambda: show_settings_screen(user_phone, shop_name))

    # Logout Button
    def logout():
        from tkinter import messagebox
        if messagebox.askyesno("Çıkış", "Oturumu kapatmak istediğinize emin misiniz?"):
            from data_manager_sqlite import clear_last_login
            from ui.login import show_login
            clear_last_login()
            show_login()

    logout_btn = tk.Button(sidebar_frame, text="🚪  Çıkış Yap", font=("Inter", 10, "bold"),
                           bg="white", fg=ACCENT_RED, bd=0, pady=20, cursor="hand2", command=logout)
    logout_btn.pack(side="bottom", fill="x")
    add_hover_effect(logout_btn, "#FFF0F0", "white")

    return sidebar_frame

def create_top_nav_bar(parent, shop_name, user_phone, active_page):
    return create_sidebar(parent, shop_name, user_phone, active_page)

def create_stat_card(parent, icon, title, value, color, click_command=None):
    """Premium Stat Card (Trendyol Style)"""
    card = tk.Frame(parent, bg="white", bd=0, highlightthickness=1, highlightbackground=BORDER_COLOR)
    card.pack(side="left", padx=(0, 20), fill="both", expand=True)
    
    if click_command:
        card.config(cursor="hand2")
        card.bind("<Button-1>", lambda e: click_command())

    # Icon Container (Modern Circle)
    icon_container = tk.Canvas(card, width=70, height=70, bg="white", highlightthickness=0)
    icon_container.pack(side="left", padx=15, pady=20)
    
    draw_rounded_rect(icon_container, 5, 5, 65, 65, radius=32, fill=NAV_ACTIVE_LIGHT, outline="")
    icon_container.create_text(35, 35, text=icon, font=("Arial", 24), fill=color)
    
    # Text Container
    text_frame = tk.Frame(card, bg="white")
    text_frame.pack(side="left", fill="both", expand=True, pady=20)
    
    tk.Label(text_frame, text=title, font=("Inter", 10, "bold"), bg="white", fg=TEXT_DIM).pack(anchor="w")
    tk.Label(text_frame, text=value, font=("Inter", 22, "bold"), bg="white", fg=TEXT_MAIN).pack(anchor="w", pady=(2, 0))
    
    # Click bindings
    if click_command:
        for w in [icon_container, text_frame]:
            w.bind("<Button-1>", lambda e: click_command())
            w.config(cursor="hand2")

    return card
