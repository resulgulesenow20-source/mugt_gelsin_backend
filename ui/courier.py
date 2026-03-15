import tkinter as tk
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager
import datetime

def show_courier_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Kurye Gün Sonu - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Sağ Yan Menü (Sidebar)
    ui.utils.create_sidebar(ui.utils.root, shop_name, user_phone, "courier")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="left", fill="both", expand=True)
    
    # Header
    header = tk.Frame(main_content, bg="white", height=90)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    title_frame = tk.Frame(header, bg="white")
    title_frame.pack(side="left", padx=40, pady=20)
    tk.Label(title_frame, text="🚚", font=("Inter", 22), bg="white").pack(side="left")
    
    text_f = tk.Frame(title_frame, bg="white")
    text_f.pack(side="left", padx=10)
    tk.Label(text_f, text="Kurye Operasyonları", font=("Inter", 18, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w")
    tk.Label(text_f, text="Gün sonu raporları ve kurye performans takibi", font=("Inter", 9), bg="white", fg=ui.utils.TEXT_DIM).pack(anchor="w")
    
    # Bugünün Tarihi
    today_str = datetime.date.today().strftime("%d %B %Y")
    tk.Label(header, text=today_str, font=("Inter", 10, "bold"), bg="white", fg=ui.utils.NAV_ACTIVE).pack(side="right", padx=40, pady=20)

    content = tk.Frame(main_content, bg="#f5f5f5")
    content.pack(fill="both", expand=True, padx=30, pady=20)
    
    # Verileri Çek
    stats = data_manager.get_today_courier_stats()
    global_stats = stats["global"]
    
    # Özet Kartları (Genel Toplam)
    tk.Label(content, text="⚡ Genel Toplam", font=("Inter", 12, "bold"), bg="#f5f5f5", fg=ui.utils.TEXT_MAIN).pack(anchor="w", pady=(0, 15))
    stats_frame = tk.Frame(content, bg="#f5f5f5")
    stats_frame.pack(fill="x", pady=(0, 20))
    
    # Kart 1: Teslim Edilen Paket (Total Packages)
    ui.utils.create_stat_card(stats_frame, "📦", "Toplam Paket", str(global_stats["total_packages"]), ui.utils.BRAND_COLOR)
    
    # Kart 2: Nakit (Cash)
    ui.utils.create_stat_card(stats_frame, "💵", "Toplam Nakit", f'₺{global_stats["kapida_nakit"]:.2f}', ui.utils.ACCENT_GREEN)
    
    # Kart 3: Kredi Kartı (POS)
    ui.utils.create_stat_card(stats_frame, "💳", "Toplam POS", f'₺{global_stats["kapida_kart"]:.2f}', ui.utils.ACCENT_ORANGE)
    
    # Kart 4: Online Ödeme
    ui.utils.create_stat_card(stats_frame, "🌐", "Online Ödenen", f'₺{global_stats["online_kart"]:.2f}', ui.utils.TEXT_DIM)

    # Kurye Bazlı Dağılım
    tk.Label(content, text="🚴 Kurye Performansı", font=("Inter", 12, "bold"), bg="#f5f5f5", fg=ui.utils.TEXT_MAIN).pack(anchor="w", pady=(10, 15))
    
    couriers_container = tk.Frame(content, bg="#f5f5f5")
    couriers_container.pack(fill="x", pady=(0, 10))
    
    if not stats["couriers"]:
        tk.Label(couriers_container, text="Henüz kurye ataması yapılmış teslimat bulunmuyor.", font=("Arial", 11), bg="#f5f5f5", fg=ui.utils.TEXT_DIM).pack(anchor="w")
    else:
        for cname, cstats in stats["couriers"].items():
            c_frame = tk.Frame(couriers_container, bg="white", bd=0, highlightthickness=1, highlightbackground="#d1d8e0", padx=15, pady=10)
            c_frame.pack(side="left", padx=(0, 15), pady=5)
            
            tk.Label(c_frame, text=f"👤 {cname}", font=("Arial", 12, "bold"), bg="white", fg=ui.utils.NAV_ACTIVE).pack(anchor="w")
            
            # Row for stats
            row = tk.Frame(c_frame, bg="white")
            row.pack(fill="x", pady=5)
            
            def add_mini_stat(parent, label, value, color):
                f = tk.Frame(parent, bg="white")
                f.pack(side="left", padx=10)
                tk.Label(f, text=label, font=("Arial", 9), bg="white", fg=ui.utils.TEXT_DIM).pack()
                tk.Label(f, text=value, font=("Arial", 11, "bold"), bg="white", fg=color).pack()

            add_mini_stat(row, "Paket", str(cstats["total_packages"]), ui.utils.TEXT_MAIN)
            add_mini_stat(row, "Nakit", f"₺{cstats['kapida_nakit']:.0f}", ui.utils.ACCENT_GREEN)
            add_mini_stat(row, "POS", f"₺{cstats['kapida_kart']:.0f}", ui.utils.ACCENT_ORANGE)

    # Gün Sonu Al Butonu
    action_frame = tk.Frame(content, bg="#f5f5f5")
    action_frame.pack(fill="x", pady=10)
    
    def on_end_day():
        tk.messagebox.showinfo("Gün Sonu", "Gün sonu raporu oluşturuldu ve hesaplar sıfırlandı (Simülasyon).")
        
    tk.Button(action_frame, text="Yazdır / Gün Sonu Al", font=("Arial", 14, "bold"), bg=ui.utils.BRAND_COLOR, fg="white", bd=0, padx=20, pady=10, cursor="hand2", command=on_end_day).pack(side="right")

    # Geçmiş Paketler Listesi
    list_frame = tk.Frame(content, bg="white", highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    list_frame.pack(fill="both", expand=True, pady=10)
    
    tk.Label(list_frame, text="✅ Bugün Teslim Edilen Paketler", font=("Inter", 12, "bold"), bg="white", fg=ui.utils.NAV_ACTIVE).pack(anchor="w", padx=20, pady=20)
    
    # Tablo Başlıkları
    header_f = tk.Frame(list_frame, bg="#f8f9fa")
    header_f.pack(fill="x", padx=20)
    
    headers = [("Tarih", 12), ("Müşteri", 20), ("Kurye", 15), ("Ödeme", 12), ("Tutar", 12)]
    for h, w in headers:
        tk.Label(header_f, text=h, font=("Arial", 11, "bold"), bg="#f1f2f6", fg=ui.utils.TEXT_DIM, width=w, anchor="w").pack(side="left", padx=5, pady=8)

    # Tablo İçeriği (Liste)
    canvas = tk.Canvas(list_frame, bg="white", highlightthickness=0)
    scrollbar = tk.Scrollbar(list_frame, orient="vertical", command=canvas.yview)
    scroll_frame = tk.Frame(canvas, bg="white")

    def _on_mousewheel(event):
        canvas.yview_scroll(int(-1*(event.delta/120)), "units")
    
    # Bind to main window or canvas area so scroll works
    canvas.bind_all("<MouseWheel>", _on_mousewheel)
    
    scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.create_window((0, 0), window=scroll_frame, anchor="nw", width=1000)
    canvas.configure(yscrollcommand=scrollbar.set)
    
    canvas.pack(side="left", fill="both", expand=True, padx=20, pady=10)
    scrollbar.pack(side="right", fill="y", pady=10)
    
    packages = data_manager.get_today_delivered_packages()
    
    if not packages:
        tk.Label(scroll_frame, text="Henüz teslim edilmiş paket bulunmuyor.", font=("Arial", 12), bg="white", fg=ui.utils.TEXT_DIM).pack(pady=20)
    else:
        for idx, pkg in enumerate(packages):
            row = tk.Frame(scroll_frame, bg="white" if idx % 2 == 0 else "#f8f9fa", pady=10)
            row.pack(fill="x")
            
            # Format time
            time_str = pkg['order_time'].split(' ')[1][:5] if pkg['order_time'] else "--:--"
            
            # Formatter for payment
            pm = pkg['payment_method']
            if pm == 'kapida_nakit':
                pm_text, pm_color = "Nakit", ui.utils.ACCENT_GREEN
            elif pm == 'kapida_kart':
                pm_text, pm_color = "POS", ui.utils.ACCENT_ORANGE
            elif pm == 'online_kart':
                pm_text, pm_color = "Online", ui.utils.NAV_ACTIVE
            else:
                pm_text, pm_color = "Belirsiz", ui.utils.TEXT_DIM

            tk.Label(row, text=time_str, font=("Arial", 11), bg=row['bg'], fg=ui.utils.TEXT_MAIN, width=12, anchor="w").pack(side="left", padx=5)
            tk.Label(row, text=pkg.get('customer_name', 'Bilinmiyor'), font=("Arial", 11, "bold"), bg=row['bg'], fg=ui.utils.TEXT_MAIN, width=20, anchor="w").pack(side="left", padx=5)
            tk.Label(row, text=pkg.get('courier_name', 'Atanmadı'), font=("Arial", 10), bg=row['bg'], fg=ui.utils.NAV_ACTIVE, width=15, anchor="w").pack(side="left", padx=5)
            tk.Label(row, text=pm_text, font=("Arial", 10, "bold"), bg=pm_color, fg="white", width=12).pack(side="left", padx=5)
            tk.Label(row, text=f"₺{pkg['total_amount']:.2f}", font=("Arial", 12, "bold"), bg=row['bg'], fg=ui.utils.TEXT_MAIN, width=12, anchor="w").pack(side="left", padx=20)

    # Don't forget to unbind mousewheel when leaving this screen
    def on_destroy(e):
        if e.widget == list_frame:
            canvas.unbind_all("<MouseWheel>")
            
    list_frame.bind("<Destroy>", on_destroy)
