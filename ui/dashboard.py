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

    # Sağ Yan Menü (Sidebar)
    ui.utils.create_sidebar(ui.utils.root, shop_name, user_phone, "dashboard")

    # Ana İçerik Alanı
    main_content = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_content.pack(side="left", fill="both", expand=True)

    # İçerik dolgusu
    content = tk.Frame(main_content, bg=ui.utils.bg_main)
    content.pack(fill="both", expand=True, padx=30, pady=20)
    
    # Header with Time/Date
    header_container = tk.Frame(content, bg=ui.utils.bg_main)
    header_container.pack(fill="x", pady=(0, 25))
    
    import datetime
    now = datetime.datetime.now()
    date_str = now.strftime("%d %B %Y, %A")
    
    greeting_frame = tk.Frame(header_container, bg=ui.utils.bg_main)
    greeting_frame.pack(side="left")
    
    tk.Label(greeting_frame, text=f"Merhaba, {shop_name} 👋", font=("Inter", 26, "bold"), bg=ui.utils.bg_main, fg=ui.utils.TEXT_MAIN, anchor="w").pack(anchor="w")
    tk.Label(greeting_frame, text=f"{date_str} • Dükkanın durumu harika!", font=("Inter", 11), bg=ui.utils.bg_main, fg=ui.utils.TEXT_DIM).pack(anchor="w", pady=(5, 0))

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

    # Start polling for new orders (Multi-Shop Global Sync)
    def poll_new_orders():
        if hasattr(ui.utils, "current_page") and ui.utils.current_page == "dashboard":
            def check_and_refresh():
                try:
                    # Attempt to fetch new orders from Render cloud backend (Network call)
                    if data_manager.fetch_remote_orders(user_phone):
                        # If new orders found, refresh the view on main thread
                        ui.utils.root.after(0, lambda: show_main_dashboard(user_phone, shop_name))
                    else:
                        # Schedule next check on main thread
                        ui.utils.root.after(10000, poll_new_orders) # Poll every 10 seconds
                except Exception as e:
                    print(f"Dashboard sync error: {e}")
                    ui.utils.root.after(10000, poll_new_orders)

            import threading
            threading.Thread(target=check_and_refresh, daemon=True).start()

    ui.utils.current_page = "dashboard"
    poll_new_orders()

def _setup_recent_orders_section(parent, user_phone, shop_name):
    # Professional container with modern spacing (Trendyol style card)
    orders_section = tk.Frame(parent, bg="white", bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    orders_section.pack(fill="both", expand=True, pady=(10, 30))
    
    # Header with premium title and button
    header_frame = tk.Frame(orders_section, bg="white", padx=20, pady=20)
    header_frame.pack(fill="x")
    
    tk.Label(header_frame, text="⚡ Son Siparişler", font=("Inter", 14, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(side="left")
    
    from ui.orders import show_orders_screen
    view_all_btn = tk.Button(header_frame, text="Tümünü Gör →", font=("Inter", 10, "bold"), bg="white", fg=ui.utils.NAV_ACTIVE, bd=0, cursor="hand2", 
                             command=lambda: show_orders_screen(user_phone, shop_name))
    view_all_btn.pack(side="right")
    ui.utils.add_hover_effect(view_all_btn, "#FFF8F5", "white")
    
    # Modern table header with soft gray background (Trendyol Style)
    table_header = tk.Frame(orders_section, bg="#F9F9F9", padx=10)
    table_header.pack(fill="x")
    
    headers = ["Platform", "Müşteri", "Km/Uzaklık", "Tabela/Not", "Sipariş Türü", "Tutar", "Ödeme", "Saat", "Durum"]
    widths = [12, 16, 12, 10, 10, 10, 10, 8, 12]
    
    for i, h in enumerate(headers):
        tk.Label(table_header, text=h, font=("Inter", 9, "bold"), bg="#F9F9F9", fg=ui.utils.TEXT_DIM, width=widths[i]).pack(side="left", padx=2, pady=15)

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
        row = tk.Frame(list_frame, bg="white")
        row.pack(fill="x")
        
        # Modern Soft Divider
        tk.Frame(list_frame, bg="#f1f2f6", height=1).pack(fill="x", padx=20)
        
        # Data Columns with premium typography
        cols = [
            ("Mugt Gelsin", ui.utils.NAV_ACTIVE), 
            (order.get("customer_name", "Bilinmiyor")[:18], ui.utils.TEXT_MAIN),
            (f"{order.get('km', '1.20')} km", ui.utils.ACCENT_GREEN),
            ("Mertca...", ui.utils.TEXT_DIM),
            ("Sipariş", ui.utils.TEXT_DIM),
            (f"₺{order.get('total_price', 0):.2f}", ui.utils.TEXT_MAIN),
            ("Online", ui.utils.ACCENT_GREEN),
            (order.get("created_at", "")[-8:-3], ui.utils.TEXT_DIM),
            (order.get("status", "Bilinmiyor"), ui.utils.NAV_ACTIVE)
        ]
        
        for i, (val, clr) in enumerate(cols):
            tk.Label(row, text=val, font=("Arial", 9, "bold" if i==0 or i==5 else "normal"), 
                     bg="white", fg=clr, width=widths[i]).pack(side="left", padx=2, pady=15)
