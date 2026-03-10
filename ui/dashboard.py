import tkinter as tk
from tkinter import messagebox
import ui.utils
from ui.utils import clear_window, create_stat_card
import data_manager_sqlite as data_manager
from PIL import Image, ImageTk
import os

def show_main_dashboard(user_phone, shop_name):
    from ui.orders import show_orders_screen

    clear_window()
    ui.utils.root.title(f"Dashboard - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg=ui.utils.bg_main)

    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "dashboard")

    # Ana İçerik Alanı
    main_content = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_content.pack(fill="both", expand=True)

    # İçerik dolgusu
    content = tk.Frame(main_content, bg=ui.utils.bg_main)
    content.pack(fill="both", expand=True, padx=30, pady=20)
    
    tk.Label(content, text=f"Hoş Geldiniz, {shop_name}", font=("Arial", 28, "bold"), bg=ui.utils.bg_main, fg=ui.utils.TEXT_MAIN).pack(anchor="w", pady=(0, 25))
    
    # Stats Cards
    stats_frame = tk.Frame(content, bg=ui.utils.bg_main)
    stats_frame.pack(fill="x", pady=(0, 30))
    
    # Fetch data from SQLite
    menu_items = data_manager.get_menu_items()
    daily_revenue = data_manager.get_daily_revenue()
    
    # Active orders count logic: count unique tables with orders
    active_orders = data_manager.get_all_active_orders_grouped()
    active_tables_count = len(active_orders.keys())
    
    from ui.menu import show_menu_screen
    create_stat_card(stats_frame, "📦", "Toplam Ürün", str(len(menu_items)), ui.utils.NAV_ACTIVE,
                    click_command=lambda: show_menu_screen(user_phone, shop_name))
    create_stat_card(stats_frame, "🔥", "Aktif Sipariş", str(active_tables_count), ui.utils.BRAND_COLOR, 
                    click_command=lambda: show_orders_screen(user_phone, shop_name))
    create_stat_card(stats_frame, "💰", "Günlük Kazanç", f"{daily_revenue:,.0f} TL", ui.utils.ACCENT_GREEN)

    # Recent Orders Section
    _setup_recent_orders_section(content, user_phone, shop_name)

def _setup_recent_orders_section(parent, user_phone, shop_name):
    orders_section = tk.Frame(parent, bg=ui.utils.CARD_BG, bd=0, relief="flat")
    orders_section.pack(fill="both", expand=True, pady=10)
    
    # Header with action button
    header_frame = tk.Frame(orders_section, bg=ui.utils.CARD_BG)
    header_frame.pack(fill="x", padx=10, pady=(10, 5))
    
    tk.Label(header_frame, text="Son Siparişler", font=("Arial", 14, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.BRAND_COLOR).pack(side="left")
    
    # Görseldeki gibi tablo başlıkları
    table_header = tk.Frame(orders_section, bg="#f1f2f6")
    table_header.pack(fill="x", padx=10)
    
    headers = ["Platform", "Müşteri", "Km/Adres", "Tabela", "S. Türü", "Tutar", "Ödeme", "Tarihi", "Durumu"]
    widths = [12, 15, 12, 10, 8, 10, 10, 12, 12]
    
    for i, h in enumerate(headers):
        tk.Label(table_header, text=h, font=("Arial", 9, "bold"), bg="#f1f2f6", fg=ui.utils.TEXT_DIM, width=widths[i]).pack(side="left", padx=2, pady=8)

    # Siparişler Listesi
    recent_orders = data_manager.get_recent_orders(limit=15)
    
    if not recent_orders:
        tk.Label(orders_section, text="Henüz sipariş bulunmuyor.", font=("Arial", 11), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(pady=40)
        return

    # Kaydırılabilir liste alanı
    canvas = tk.Canvas(orders_section, bg=ui.utils.CARD_BG, highlightthickness=0)
    canvas.pack(side="left", fill="both", expand=True, padx=10)
    
    scrollbar = tk.Scrollbar(orders_section, orient="vertical", command=canvas.yview)
    scrollbar.pack(side="right", fill="y")
    
    canvas.configure(yscrollcommand=scrollbar.set)
    
    list_frame = tk.Frame(canvas, bg=ui.utils.CARD_BG)
    canvas.create_window((0,0), window=list_frame, anchor="nw")
    
    def on_configure(event):
        canvas.configure(scrollregion=canvas.bbox("all"))
        canvas.itemconfig(1, width=event.width)
    
    canvas.bind('<Configure>', on_configure)

    # Mouse Wheel Support
    def _on_mousewheel(event):
        canvas.yview_scroll(int(-1*(event.delta/120)), "units")
    canvas.bind_all("<MouseWheel>", _on_mousewheel)

    for order in recent_orders:
        row = tk.Frame(list_frame, bg=ui.utils.CARD_BG)
        row.pack(fill="x")
        
        # Çizgi ayırıcı (Daha temiz ve belirgin)
        tk.Frame(list_frame, bg="#f1f2f6", height=1).pack(fill="x")
        
        # Sütun verileri (Canlı renkler)
        cols = [
            ("Mugt Gelsin", ui.utils.BRAND_COLOR), 
            (order.get("customer_name", "Bilinmiyor")[:15], ui.utils.TEXT_MAIN),
            (f"{order.get('km', '1.20')} km", ui.utils.ACCENT_GREEN),
            ("Mertca...", ui.utils.TEXT_DIM),
            ("Sipariş", ui.utils.NAV_ACTIVE),
            (f"₺{order.get('total_price', 0):.2f}", ui.utils.TEXT_MAIN),
            ("Online", ui.utils.ACCENT_GREEN),
            (order.get("created_at", "")[-8:-3], ui.utils.TEXT_DIM),
            (order.get("status", "Bilinmiyor"), ui.utils.NAV_ACTIVE)
        ]
        
        for i, (val, clr) in enumerate(cols):
            tk.Label(row, text=val, font=("Arial", 9, "bold" if i==0 else "normal"), bg=ui.utils.CARD_BG, fg=clr, width=widths[i]).pack(side="left", padx=2, pady=12)
