import tkinter as tk
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager

def show_reports_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Raporlar - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Sağ Yan Menü (Sidebar)
    ui.utils.create_sidebar(ui.utils.root, shop_name, user_phone, "reports")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="left", fill="both", expand=True)
    
    # Header with premium title and date range indicator
    header = tk.Frame(main_content, bg="white", height=90)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    title_frame = tk.Frame(header, bg="white")
    title_frame.pack(side="left", padx=40, pady=20)
    tk.Label(title_frame, text="📊", font=("Inter", 22), bg="white").pack(side="left")
    
    text_f = tk.Frame(title_frame, bg="white")
    text_f.pack(side="left", padx=10)
    tk.Label(text_f, text="Finansal Raporlar", font=("Inter", 18, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w")
    tk.Label(text_f, text=f"İşletmenizin performans özeti", font=("Inter", 9), bg="white", fg=ui.utils.TEXT_DIM).pack(anchor="w")
    
    content = tk.Frame(main_content, bg="#f5f5f5")
    content.pack(fill="both", expand=True, padx=30, pady=20)
    
    # Dashboard-like summary cards
    stats_frame = tk.Frame(content, bg="#f5f5f5")
    stats_frame.pack(fill="x", pady=(0, 20))
    
    # Real Data Calculation
    menu_items = data_manager.get_menu_items()
    
    total_sales = data_manager.get_total_revenue()
    total_orders_count = data_manager.get_total_orders_count()
    avg_basket = total_sales / total_orders_count if total_orders_count else 0
    
    ui.utils.create_stat_card(stats_frame, "💰", "Toplam Ciro", f"{total_sales:.2f} TL", ui.utils.ACCENT_GREEN)
    ui.utils.create_stat_card(stats_frame, "🧾", "Toplam Sipariş", str(total_orders_count), ui.utils.BRAND_COLOR)
    ui.utils.create_stat_card(stats_frame, "🛒", "Ort. Sepet", f"{avg_basket:.2f} TL", ui.utils.NAV_ACTIVE)

    
    # Premium Chart Visualization (Canvas)
    chart_frame = tk.Frame(content, bg="white", bd=0, highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR, height=320)
    chart_frame.pack(fill="both", expand=True, pady=10)
    chart_frame.pack_propagate(False)
    
    tk.Label(chart_frame, text="⚡ Haftalık Satış Performansı", font=("Inter", 12, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w", padx=25, pady=(20, 0))
    
    canvas = tk.Canvas(chart_frame, bg="white", highlightthickness=0)
    canvas.pack(fill="both", expand=True, padx=20, pady=(0, 20))
    
    # Real Data
    sales_map = data_manager.get_weekly_sales_data()
    # Ensure we have 7 days even if empty
    import datetime
    today = datetime.date.today()
    days = []
    data = []
    
    for i in range(6, -1, -1):
        d = today - datetime.timedelta(days=i)
        d_str = d.strftime('%Y-%m-%d')
        days.append(d.strftime('%d %b')) # Display format
        data.append(sales_map.get(d_str, 0))
    
    max_val = max(data) if data and max(data) > 0 else 100
    
    c_width = 800
    c_height = 200
    bar_width = 60
    spacing = 50
    start_x = 50
    start_y = 220 
    
    # Draw Background Grid Lines
    for i in range(5):
        y_line = start_y - (i * 45)
        canvas.create_line(40, y_line, 850, y_line, fill="#f1f2f6", dash=(4, 4))
        if i > 0:
            grid_val = int((i / 4) * max_val)
            canvas.create_text(20, y_line, text=f"{grid_val}", font=("Arial", 9), fill=ui.utils.TEXT_DIM)
    

    # Hover Effects storage
    bar_rects = []
    
    for i, val in enumerate(data):
        bar_h = (val / max_val) * 180
        x0 = start_x + (i * (bar_width + spacing))
        y0 = start_y
        x1 = x0 + bar_width
        y1 = start_y - bar_h
        
        # Soft shadow / background bar
        ui.utils.draw_rounded_rect(canvas, x0, y1, x1, y0, radius=10, fill="#f8f9fa", outline="")
            
        # Main Bar matching brand theme with vibrant orange
        bar_id = ui.utils.draw_rounded_rect(canvas, x0, y1, x1, y0, radius=10, fill=ui.utils.BRAND_COLOR, outline="")
            
        bar_rects.append(bar_id)
        
        if val > 0:
            canvas.create_text(x0 + bar_width/2, y1 - 15, text=f"₺{val:,.0f}", font=("Inter", 9, "bold"), fill=ui.utils.TEXT_MAIN)
            
        canvas.create_text(x0 + bar_width/2, y0 + 15, text=days[i], font=("Inter", 9), fill=ui.utils.TEXT_DIM)
        
    # Bind hover effects
    def on_enter(event):
        current = canvas.find_withtag("current")
        if current and current[0] in bar_rects:
            canvas.itemconfig(current[0], fill="#ff8c00") # Brighter orange on hover
            canvas.config(cursor="hand2")

    def on_leave(event):
        current = canvas.find_withtag("current")
        if current and current[0] in bar_rects:
            canvas.itemconfig(current[0], fill=ui.utils.BRAND_COLOR)
            canvas.config(cursor="")
            
    canvas.bind("<Enter>", on_enter)
    canvas.bind("<Leave>", on_leave)
    canvas.tag_bind("all", "<Enter>", on_enter)
    canvas.tag_bind("all", "<Leave>", on_leave)

    
    # Top Products
    top_prod_frame = tk.Frame(content, bg="white", bd=0, highlightthickness=1, highlightbackground="#d1d8e0")
    top_prod_frame.pack(fill="x", pady=10, ipady=10)
    
    tk.Label(top_prod_frame, text="🏆 En Çok Satılan Ürünler", font=("Arial", 16, "bold"), bg="white", fg=ui.utils.NAV_ACTIVE).pack(anchor="w", padx=20, pady=15)
    
    # Real Top Products
    demos = data_manager.get_top_products(limit=5)
    
    if not demos:
         tk.Label(top_prod_frame, text="Henüz satış verisi yok.", font=("Arial", 12), bg="white", fg=ui.utils.TEXT_DIM).pack(pady=10)
    
    # Find max for progress bar
    max_qty = demos[0][1] if demos else 100
    
    for idx, (name, qty) in enumerate(demos):
        row = tk.Frame(top_prod_frame, bg="white", pady=8)
        row.pack(fill="x", padx=20)
        
        # Trophy/Rank Icon color logic
        if idx == 0:
            rank_color = "#FFD700" # Gold
        elif idx == 1:
            rank_color = "#C0C0C0" # Silver
        elif idx == 2:
            rank_color = "#CD7F32" # Bronze
        else:
            rank_color = ui.utils.TEXT_DIM
            
        tk.Label(row, text=f"#{idx+1}", font=("Arial", 14, "bold"), bg="white", fg=rank_color, width=4, anchor="w").pack(side="left")
        tk.Label(row, text=name, bg="white", font=("Arial", 13, "bold"), fg=ui.utils.TEXT_MAIN, width=25, anchor="w").pack(side="left")
        
        # Modern rounded-style progress bar via Canvas
        p_canvas = tk.Canvas(row, width=300, height=14, bg="white", highlightthickness=0)
        p_canvas.pack(side="left", padx=20, expand=True, fill="x")
        
        # Draw soft background bar
        p_canvas.create_polygon(5,0, 295,0, 300,0, 300,5, 300,9, 300,14, 295,14, 5,14, 0,14, 0,9, 0,5, 0,0, fill="#ecf0f1", smooth=True)
        
        # Calculate width relative to 300px
        p_width = (qty / max_qty) * 300
        prad = 5 if p_width > 10 else int(p_width/2)
        if prad < 2: prad = 0
            
        if p_width > 5:
            # Draw rounded active bar
            p_canvas.create_polygon(prad,0, p_width-prad,0, p_width,0, p_width,prad, p_width,14-prad, p_width,14, p_width-prad,14, prad,14, 0,14, 0,14-prad, 0,prad, 0,0, fill=ui.utils.ACCENT_ORANGE, smooth=True)
        else:
            p_canvas.create_rectangle(0, 0, p_width, 14, fill=ui.utils.ACCENT_ORANGE, outline="")
        
        tk.Label(row, text=f"{qty} Adet", bg="white", font=("Arial", 13, "bold"), fg=ui.utils.TEXT_MAIN).pack(side="right")
        
        tk.Frame(top_prod_frame, bg="#f5f6fa", height=1).pack(fill="x", padx=40) # separator


