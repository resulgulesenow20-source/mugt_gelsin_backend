import tkinter as tk
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager

def show_reports_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Raporlar - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "reports")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="right", fill="both", expand=True)
    
    # Header
    header = tk.Frame(main_content, bg="white", height=60)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    tk.Label(header, text="📈 Raporlar", font=("Arial", 26, "bold"), bg="white", fg="#333").pack(side="left", padx=30, pady=15)
    
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
    
    ui.utils.create_stat_card(stats_frame, "💰", "Toplam Ciro", f"{total_sales:.2f} TL", "#2ecc71")
    ui.utils.create_stat_card(stats_frame, "🧾", "Toplam Sipariş", str(total_orders_count), "#3498db")
    ui.utils.create_stat_card(stats_frame, "🛒", "Ort. Sepet", f"{avg_basket:.2f} TL", "#9b59b6")

    
    # Simple Chart Visualization (Canvas)
    chart_frame = tk.Frame(content, bg="white", bd=1, relief="solid", height=300)
    chart_frame.pack(fill="both", expand=True, pady=10)
    chart_frame.pack_propagate(False)
    
    tk.Label(chart_frame, text="Son 7 Gün Satış Grafiği", font=("Arial", 18, "bold"), bg="white").pack(anchor="w", padx=20, pady=10)
    
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
    bar_width = 50
    spacing = 40
    start_x = 50
    start_y = 220 
    
    for i, val in enumerate(data):
        bar_h = (val / max_val) * 180
        x0 = start_x + (i * (bar_width + spacing))
        y0 = start_y
        x1 = x0 + bar_width
        y1 = start_y - bar_h
        
        canvas.create_rectangle(x0, y0, x1, y1, fill="#3498db", outline="")
        canvas.create_text(x0 + bar_width/2, y1 - 10, text=f"{val}", font=("Arial", 13))
        canvas.create_text(x0 + bar_width/2, y0 + 15, text=days[i], font=("Arial", 13, "bold"))

    
    # Top Products
    top_prod_frame = tk.Frame(content, bg="white", bd=1, relief="solid")
    top_prod_frame.pack(fill="x", pady=10, ipady=10)
    
    tk.Label(top_prod_frame, text="En Çok Satılan Ürünler", font=("Arial", 18, "bold"), bg="white").pack(anchor="w", padx=20, pady=10)
    
    # Real Top Products
    demos = data_manager.get_top_products(limit=5)
    
    if not demos:
         tk.Label(top_prod_frame, text="Henüz satış verisi yok.", font=("Arial", 14), bg="white", fg="#999").pack(pady=10)
    
    # Find max for progress bar
    max_qty = demos[0][1] if demos else 100
    
    for name, qty in demos:
        row = tk.Frame(top_prod_frame, bg="white", pady=5)
        row.pack(fill="x", padx=20)
        tk.Label(row, text=name, bg="white", font=("Arial", 14)).pack(side="left")
        
        # Simple progress bar
        p_canvas = tk.Canvas(row, width=200, height=10, bg="#ecf0f1", highlightthickness=0)
        p_canvas.pack(side="left", padx=20)
        p_width = (qty / max_qty) * 200
        p_canvas.create_rectangle(0, 0, p_width, 10, fill="#e67e22", outline="")
        
        tk.Label(row, text=f"{qty} Adet", bg="white", font=("Arial", 16, "bold"), fg="#e67e22").pack(side="right")


