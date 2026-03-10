import tkinter as tk
from tkinter import messagebox
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager
import threading
import sys
if sys.platform == "win32":
    import winsound

# Global flag to prevent multiple sync threads
_sync_thread_active = False

def show_orders_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Sipariş Ekranı - {shop_name}")
    ui.utils.root.geometry("1200x800")
    ui.utils.root.configure(bg=ui.utils.bg_main)
    
    # Yeni Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "orders")
    ui.utils.current_page = "orders"
    
    # Ana İçerik Alanı (Kaydırılabilir olabilir)
    main_content = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_content.pack(fill="both", expand=True)
    
    # Operasyonel Kontrol Paneli
    _setup_operational_controls(main_content, user_phone, shop_name)
    
    # Sipariş Listeleri Alanı
    lists_container = tk.Frame(main_content, bg=ui.utils.bg_main)
    lists_container.pack(fill="both", expand=True, padx=10, pady=10)
    
    # 1. Yeni Sipariş Bölümü
    _setup_new_orders_section(lists_container)
    
    # 2. Yola Çıkarılması Gereken Siparişler
    _setup_to_ship_section(lists_container, user_phone, shop_name)
    
    # 3. Teslim Edilmesi Gereken Siparişler
    _setup_to_deliver_section(lists_container, user_phone, shop_name)
    
    # Start Sync Loop
    _start_sync_loop(ui.utils.root, user_phone, shop_name)

def _setup_operational_controls(parent, user_phone, shop_name):
    controls_frame = tk.Frame(parent, bg=ui.utils.CARD_BG, pady=15, bd=0, relief="flat")
    controls_frame.pack(fill="x", padx=20, pady=10)
    
    def toggle_setting(key, current_val, options):
        new_val = options[1] if current_val == options[0] else options[0]
        data_manager.update_setting(key, new_val)
        if key == "shop_status":
            data_manager.sync_profile_to_remote()
        show_orders_screen(user_phone, shop_name)

    def create_control(label, key, options, active_color):
        current_val = data_manager.get_setting(key, options[0])
        is_active = (current_val == options[0])
        
        f = tk.Frame(controls_frame, bg=ui.utils.CARD_BG)
        f.pack(side="left", padx=15)
        tk.Label(f, text=label, font=("Arial", 9, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(anchor="w")
        
        btn_color = active_color if is_active else "#dfe4ea"
        btn = tk.Button(f, text=f"{current_val}  ▼", font=("Arial", 10, "bold"), 
                       bg=btn_color, fg="white", bd=0, padx=20, pady=7, cursor="hand2",
                       command=lambda: toggle_setting(key, current_val, options))
        btn.pack(pady=2)

    create_control("Restoran Durumu", "shop_status", ["AÇIK", "KAPALI"], ui.utils.ACCENT_GREEN)
    create_control("Otomatik Onay", "auto_confirm", ["AÇIK", "KAPALI"], ui.utils.NAV_ACTIVE)
    create_control("Yola Çıkar/Teslim Et", "dispatch_mode", ["AÇIK", "KAPALI"], ui.utils.ACCENT_GREEN)
    
    # Ortalama Teslimat Süresi (Basit Seçim)
    def set_delivery_time():
        current = data_manager.get_setting("avg_delivery_time", "20 dk")
        new_time = "30 dk" if current == "20 dk" else "20 dk"
        data_manager.update_setting("avg_delivery_time", new_time)
        show_orders_screen(user_phone, shop_name)

    f_time = tk.Frame(controls_frame, bg=ui.utils.CARD_BG)
    f_time.pack(side="left", padx=15)
    tk.Label(f_time, text="Ort. Teslimat Süresi", font=("Arial", 9, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(anchor="w")
    tk.Button(f_time, text=f"{data_manager.get_setting('avg_delivery_time', '20 dk')}  ▼", font=("Arial", 10, "bold"),
              bg=ui.utils.ACCENT_ORANGE, fg="white", bd=0, padx=20, pady=7, cursor="hand2", command=set_delivery_time).pack(pady=2)

    # Kurye Firması
    f_courier = tk.Frame(controls_frame, bg=ui.utils.CARD_BG)
    f_courier.pack(side="left", padx=15)
    tk.Label(f_courier, text="Kurye Firmasına Aktar", font=("Arial", 9, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(anchor="w")
    tk.Button(f_courier, text="KAPALI  ▼", font=("Arial", 10, "bold"), bg="#dfe4ea", fg="#57606f", bd=0, padx=20, pady=7, cursor="hand2").pack(pady=2)

    # Sağdaki ikonlar
    right_f = tk.Frame(controls_frame, bg=ui.utils.CARD_BG)
    right_f.pack(side="right", padx=10)
    tk.Label(right_f, text="👁️", font=("Arial", 14), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).pack(side="left", padx=5)
    for p, clr in [("M", ui.utils.BRAND_COLOR), ("T", ui.utils.ACCENT_ORANGE), ("G", ui.utils.NAV_ACTIVE)]:
        tk.Label(right_f, text=p, font=("Arial", 10, "bold"), bg=ui.utils.CARD_BG, fg=clr, bd=1, relief="solid", width=2).pack(side="left", padx=2)

def _setup_new_orders_section(parent):
    section_frame = tk.Frame(parent, bg=ui.utils.bg_main)
    section_frame.pack(fill="x", pady=(0, 20))
    
    tk.Label(section_frame, text="Yeni Sipariş", font=("Arial", 11, "bold"), bg=ui.utils.bg_main, fg=ui.utils.BRAND_COLOR).pack(anchor="w")
    
    header_f = tk.Frame(section_frame, bg="#f1f2f6")
    header_f.pack(fill="x")
    
    headers = ["Platform", "Müşteri", "Km/Adres", "Tabela", "S. Türü", "Tutar", "Ödeme", "Tarihi", "Durumu", "Detay"]
    for h in headers:
        tk.Label(header_f, text=h, font=("Arial", 9, "bold"), bg="#f1f2f6", fg=ui.utils.TEXT_DIM, width=12).pack(side="left", padx=2, pady=8)

    # Örnek boş satır mesajı
    tk.Label(section_frame, text="Şu an yeni sipariş bulunmuyor.", bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM, pady=10).pack(fill="x")

def _setup_to_ship_section(parent, user_phone, shop_name):
    section_frame = tk.Frame(parent, bg=ui.utils.bg_main)
    section_frame.pack(fill="x", pady=(0, 20))
    
    tk.Label(section_frame, text="Yola Çıkarılması Gereken Siparişler", font=("Arial", 11, "bold"), bg=ui.utils.bg_main, fg=ui.utils.BRAND_COLOR).pack(anchor="w")
    
    # Sipariş Kartları (Görseldeki Yemeksepeti/Trendyol kartları gibi)
    active_orders = data_manager.get_all_active_orders_grouped()
    for tid, items in active_orders.items():
        # Sadece "Hazırlanıyor" olanları burada göster
        if any(i.get('status') == 'Hazırlanıyor' for i in items):
            _create_order_card(section_frame, tid, items, "SHIP", user_phone, shop_name)

def _setup_to_deliver_section(parent, user_phone, shop_name):
    section_frame = tk.Frame(parent, bg=ui.utils.bg_main)
    section_frame.pack(fill="x", pady=(0, 20))
    
    tk.Label(section_frame, text="Teslim Edilmesi Gereken Siparişler", font=("Arial", 11, "bold"), bg=ui.utils.bg_main, fg=ui.utils.NAV_ACTIVE).pack(anchor="w")
    
    active_orders = data_manager.get_all_active_orders_grouped()
    for tid, items in active_orders.items():
        # Sadece "Yola Çıktı" olanları burada göster
        if any(i.get('status') == 'Yola Çıktı' for i in items):
            _create_order_card(section_frame, tid, items, "DELIVER", user_phone, shop_name)

def _create_order_card(parent, tid, items, mode, user_phone, shop_name):
    first = items[0]
    # Kartın arkasına daha belirgin bir gölge hissi
    shadow_frame = tk.Frame(parent, bg="#d1ccc0", pady=2)
    shadow_frame.pack(fill="x", pady=8)
    
    card = tk.Frame(shadow_frame, bg=ui.utils.CARD_BG, pady=15, bd=0)
    card.pack(fill="x")
    
    # Sol: Platform Logo (Canlı renkler)
    platform = "Mugt Gelsin" 
    p_color = ui.utils.BRAND_COLOR if mode == "SHIP" else ui.utils.NAV_ACTIVE
    
    tk.Label(card, text=platform, font=("Arial", 12, "bold italic"), fg=p_color, bg=ui.utils.CARD_BG, width=15).pack(side="left", padx=15)
    
    # Orta Bilgiler (Daha temiz fontlar)
    info_f = tk.Frame(card, bg=ui.utils.CARD_BG)
    info_f.pack(side="left", expand=True, fill="x")
    
    tk.Label(info_f, text=first.get('customer_name', 'Bilinmiyor'), font=("Arial", 11, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_MAIN).grid(row=0, column=0, sticky="w")
    tk.Label(info_f, text=f"{items[0].get('customer_address', '')[:40]}...", font=("Arial", 10), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_DIM).grid(row=1, column=0, sticky="w")
    
    # Sağ: Fiyat ve Butonlar
    total = sum(i['price'] * i['quantity'] for i in items)
    tk.Label(card, text=f"₺{total:.2f}", font=("Arial", 14, "bold"), bg=ui.utils.CARD_BG, fg=ui.utils.TEXT_MAIN).pack(side="left", padx=20)
    
    btn_frame = tk.Frame(card, bg=ui.utils.CARD_BG)
    btn_frame.pack(side="right", padx=15)
    
    def update_status():
        new_status = "Yola Çıktı" if mode == "SHIP" else "Teslim Edildi"
        for item in items:
            data_manager.update_order_status(item['id'], new_status)
        show_orders_screen(user_phone, shop_name)

    tk.Button(btn_frame, text="İptal Et", bg=ui.utils.BRAND_COLOR, fg="white", bd=0, padx=12, pady=5, font=("Arial", 9, "bold"), cursor="hand2").pack(side="left", padx=5)
    
    btn_text = "Yola Çıkar" if mode == "SHIP" else "Teslim Et"
    tk.Button(btn_frame, text=btn_text, bg=ui.utils.ACCENT_GREEN, fg="white", bd=0, padx=18, pady=5, font=("Arial", 9, "bold"), cursor="hand2",
              command=update_status).pack(side="left", padx=5)
    
    tk.Button(btn_frame, text="🔍", bg="#f1f2f6", fg=ui.utils.TEXT_MAIN, bd=0, padx=10, pady=5, cursor="hand2",
              command=lambda: _show_order_details_modal(items)).pack(side="left", padx=5)

def _start_sync_loop(root, user_phone, shop_name):
    """Arka planda yeni siparişleri kontrol eder (Non-blocking)"""
    global _sync_thread_active
    
    # Sadece siparişler ekranındaysak ve hali hazırda bir sync çalışmıyorsa devam et
    if not hasattr(ui.utils, "current_page") or ui.utils.current_page != "orders" or _sync_thread_active:
        return

    def sync_task():
        global _sync_thread_active
        # Dükkan durumu kontrolü
        if data_manager.get_setting("shop_status", "AÇIK") == "KAPALI":
            _sync_thread_active = False
            # 5 saniye sonra tekrar kontrol et
            root.after(5000, lambda: _start_sync_loop(root, user_phone, shop_name))
            return

        _sync_thread_active = True
        try:
            # Bu işlem internet hızı ve sunucu yanıtına göre zaman alabilir (blocking)
            new_arrived = data_manager.fetch_remote_orders(user_phone)
            
            # Eğer dükkan sahibi hala siparişler ekranındaysa ve yeni sipariş geldiyse UI'ı güncelle
            if new_arrived and hasattr(ui.utils, "current_page") and ui.utils.current_page == "orders":
                # Sipariş sesi çal
                if sys.platform == "win32":
                    try:
                        # Play a standard Windows notification sound asynchronously
                        winsound.PlaySound("SystemAsterisk", winsound.SND_ALIAS | winsound.SND_ASYNC)
                    except:
                        pass
                
                root.after(0, lambda: show_orders_screen(user_phone, shop_name))
                # Not: show_orders_screen tekrar _start_sync_loop çağıracağı için 
                # _sync_thread_active burada False yapılmalı ki yeni loop başlasın.
                _sync_thread_active = False
                return
        except Exception as e:
            print(f"Sync thread error: {e}")
        
        # İşlem bitti (hata olsa da olmasa da)
        _sync_thread_active = False
        
        # 5 saniye sonra ana thread üzerinden tekrar tetikle
        if hasattr(ui.utils, "current_page") and ui.utils.current_page == "orders":
            root.after(5000, lambda: _start_sync_loop(root, user_phone, shop_name))

    # Arka plan kanalını başlat
    threading.Thread(target=sync_task, daemon=True).start()

# Eski bölümler kaldırıldı, yeni modüler yapıya geçildi.

def _show_order_details_modal(items):
    if not items: return
    first = items[0]
    
    modal = tk.Toplevel(ui.utils.root)
    modal.title("Sipariş Detayları")
    modal.geometry("500x400")
    modal.configure(bg="#f5f5f5")
    
    tk.Label(modal, text="📋 Sipariş Bilgileri", font=("Arial", 22, "bold"), bg="#f5f5f5").pack(pady=20)
    
    info_frame = tk.Frame(modal, bg="white", padx=20, pady=20, bd=1, relief="solid")
    info_frame.pack(padx=20, fill="both")
    
    def add_info_row(icon, label, value):
        row = tk.Frame(info_frame, bg="white", pady=5)
        row.pack(fill="x")
        tk.Label(row, text=f"{icon} {label}:", font=("Arial", 14, "bold"), bg="white", width=12, anchor="e").pack(side="left")
        tk.Label(row, text=value or "Belirtilmemiş", font=("Arial", 14), bg="white", wraplength=300, justify="left").pack(side="left", padx=10)

    add_info_row("👤", "Müşteri", first.get('customer_name'))
    add_info_row("📞", "Telefon", first.get('customer_phone'))
    add_info_row("📍", "Adres", first.get('customer_address'))
    add_info_row("📝", "Not", first.get('note'))
    
    tk.Button(modal, text="KAPAT", font=("Arial", 14, "bold"), command=modal.destroy, bg="#e74c3c", fg="white", pady=10).pack(pady=20)

def open_create_order_modal(user_phone, shop_name):
    modal = tk.Toplevel(ui.utils.root)
    modal.title("Yeni Sipariş Oluştur")
    modal.geometry("900x700")
    modal.configure(bg="#f5f5f5")
    
    left_panel = tk.Frame(modal, bg="white", width=500)
    left_panel.pack(side="left", fill="both", expand=True, padx=10, pady=10)
    
    tk.Label(left_panel, text="Menüden Ürün Seçin", font=("Arial", 18, "bold"), bg="white").pack(pady=10)
    
    categories = ["Tümü", "Ana Yemekler", "Ara Sıcaklar", "İçecekler", "Tatlılar", "Diğer"]
    current_category = tk.StringVar(value="Tümü")
    
    tabs_frame = tk.Frame(left_panel, bg="white")
    tabs_frame.pack(fill="x", pady=(0, 10))
    
    def filter_menu(cat):
        current_category.set(cat)
        refresh_menu_list()
        
    for cat in categories:
        tk.Button(tabs_frame, text=cat, font=("Arial", 14), bg="#ecf0f1", fg="#333", bd=0, padx=10,
                  command=lambda c=cat: filter_menu(c)).pack(side="left", padx=2)
        
    menu_canvas = tk.Canvas(left_panel, bg="white")
    menu_canvas.pack(side="left", fill="both", expand=True)
    menu_scroll = tk.Scrollbar(left_panel, orient="vertical", command=menu_canvas.yview)
    menu_scroll.pack(side="right", fill="y")
    menu_canvas.configure(yscrollcommand=menu_scroll.set)
    menu_canvas.bind('<Configure>', lambda e: menu_canvas.configure(scrollregion=menu_canvas.bbox("all")))
    
    menu_frame = tk.Frame(menu_canvas, bg="white")
    menu_canvas.create_window((0,0), window=menu_frame, anchor="nw", width=450)
    
    menu_items = data_manager.get_menu_items()
    selected_items = {} # {item_id: {data: item, qty: 0}}
    
    right_panel = tk.Frame(modal, bg="#f5f5f5", width=350)
    right_panel.pack(side="right", fill="y", padx=10, pady=10)
    
    tk.Label(right_panel, text="Müşteri Bilgileri", font=("Arial", 18, "bold"), bg="#f5f5f5").pack(anchor="w", pady=(0, 5))
    
    def create_input(parent, placeholder):
        entry = tk.Entry(parent, font=("Arial", 14), width=35, fg="grey")
        entry.insert(0, placeholder)
        def on_focus_in(e):
            if entry.get() == placeholder:
                entry.delete(0, tk.END)
                entry.config(fg="black")
        def on_focus_out(e):
            if not entry.get():
                entry.insert(0, placeholder)
                entry.config(fg="grey")
        entry.bind("<FocusIn>", on_focus_in)
        entry.bind("<FocusOut>", on_focus_out)
        entry.pack(pady=5)
        return entry

    e_name = create_input(right_panel, "Müşteri Adı Soyadı")
    e_phone = create_input(right_panel, "Telefon Numarası")
    e_address = create_input(right_panel, "Adres (Mahalle, Cadde, No...)")
    e_note = create_input(right_panel, "Sipariş Notu")
    
    tk.Label(right_panel, text="Sepet", font=("Arial", 18, "bold"), bg="#f5f5f5").pack(anchor="w", pady=(20, 5))
    cart_list = tk.Listbox(right_panel, width=40, font=("Arial", 12), height=15)
    cart_list.pack(fill="x")
    
    lbl_total = tk.Label(right_panel, text="Toplam: 0.0 TL", font=("Arial", 24, "bold"), bg="#f5f5f5", fg="#2ecc71")
    lbl_total.pack(pady=10)
    
    def update_cart_display():
        cart_list.delete(0, tk.END)
        total = 0
        for iid, data in selected_items.items():
            qty = data['qty']
            if qty > 0:
                item = data['data']
                line_total = item['price'] * qty
                total += line_total
                cart_list.insert(tk.END, f"{item['name']} x{qty} - {line_total:.2f} TL")
        lbl_total.config(text=f"Toplam: {total:.2f} TL")

    def add_to_cart(item):
        current_stock = item.get('stock', 0)
        in_cart_qty = selected_items.get(item['id'], {}).get('qty', 0)
        
        if in_cart_qty + 1 > current_stock:
            messagebox.showwarning("Yetersiz Stok", f"{item['name']} ürününden sadece {current_stock} adet stokta var.")
            return

        if item['id'] not in selected_items:
            selected_items[item['id']] = {'data': item, 'qty': 0}
        selected_items[item['id']]['qty'] += 1
        update_cart_display()

    def refresh_menu_list():
        for widget in menu_frame.winfo_children():
            widget.destroy()
            
        cat_filter = current_category.get()
        for item in menu_items:
            if cat_filter != "Tümü" and item.get('category', 'Diğer') != cat_filter:
                continue
                
            row = tk.Frame(menu_frame, bg="white", bd=1, relief="solid", pady=5)
            row.pack(fill="x", pady=2, padx=5)
            
            tk.Label(row, text=item['icon'], font=("Arial", 20), bg="white").pack(side="left", padx=5)
            tk.Label(row, text=item['name'], font=("Arial", 16, "bold"), bg="white", width=20, anchor="w").pack(side="left")
            
            stock = item.get('stock', 0)
            stock_color = "#e74c3c" if stock < 5 else "#7f8c8d"
            tk.Label(row, text=f"Stok: {stock}", font=("Arial", 14), bg="white", fg=stock_color).pack(side="left", padx=5)
            
            tk.Label(row, text=f"{item['price']} TL", font=("Arial", 16), bg="white", fg="#27ae60").pack(side="left", padx=5)
            
            tk.Button(row, text="Ekle +", bg="#3498db", fg="white", font=("Arial", 16, "bold"), bd=0, 
                      cursor="hand2", command=lambda i=item: add_to_cart(i)).pack(side="right", padx=5)
    
    refresh_menu_list()

    def submit_order():
        if not selected_items:
            messagebox.showwarning("Uyarı", "Sepet boş!")
            return
            
        c_name = e_name.get()
        c_phone = e_phone.get()
        c_address = e_address.get()
        c_note = e_note.get()
        
        if c_name == "Müşteri Adı Soyadı": c_name = ""
        if c_phone == "Telefon Numarası": c_phone = ""
        if c_address == "Adres (Mahalle, Cadde, No...)": c_address = ""
        if c_note == "Sipariş Notu": c_note = ""
        
        import time
        ticket_id = int(time.time() * 1000) % 1000000
        
        for iid, data in selected_items.items():
            qty = data['qty']
            item = data['data']
            if qty > 0:
                data_manager.add_order_item(ticket_id, item['name'], item['price'], qty, "Hazırlanıyor", c_name, c_phone, c_address, c_note)
                data_manager.decrease_stock(item['id'], qty)

        modal.destroy()
        show_orders_screen(user_phone, shop_name)

    tk.Button(right_panel, text="SİPARİŞİ OLUŞTUR", bg="#27ae60", fg="white", font=("Arial", 18, "bold"), 
              pady=10, command=submit_order).pack(fill="x", pady=10)
