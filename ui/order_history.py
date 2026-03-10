import tkinter as tk
from tkinter import messagebox
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager

def show_order_history_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Sipariş Geçmişi - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "history")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="right", fill="both", expand=True)
    
    # Header
    header = tk.Frame(main_content, bg="white", height=60)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    tk.Label(header, text="📋 Sipariş Geçmişi", font=("Arial", 26, "bold"), bg="white", fg="#333").pack(side="left", padx=30, pady=15)
    
    content = tk.Frame(main_content, bg="#f5f5f5")
    content.pack(fill="both", expand=True, padx=30, pady=20)
    
    # Orders List Frame with Scrollbar
    list_frame = tk.Frame(content, bg="#f5f5f5")
    list_frame.pack(fill="both", expand=True)
    
    canvas = tk.Canvas(list_frame, bg="#f5f5f5", highlightthickness=0)
    scrollbar = tk.Scrollbar(list_frame, orient="vertical", command=canvas.yview)
    scroll_content = tk.Frame(canvas, bg="#f5f5f5")
    
    scroll_content.bind(
        "<Configure>",
        lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
    )
    
    canvas.create_window((0, 0), window=scroll_content, anchor="nw")
    canvas.configure(yscrollcommand=scrollbar.set)
    
    canvas.pack(side="left", fill="both", expand=True)
    scrollbar.pack(side="right", fill="y")
    
    # Load History
    history = data_manager.get_order_history()
    
    if not history:
        tk.Label(scroll_content, text="Henüz tamamlanmış sipariş yok.", font=("Arial", 18), bg="#f5f5f5", fg="#999").pack(pady=50)
        return

    # Grouping by table_id and date for grouping into cards
    # Since we don't have a formal "Order ID", we group by unique customer+table+time combos
    grouped_history = {}
    for o in history:
        # Create a unique key for the order session
        # Using phone + table_id + truncated created_at (minute precision)
        # Note: created_at is 'YYYY-MM-DD HH:MM:SS'
        time_key = o['created_at'][:16] # YYYY-MM-DD HH:MM
        key = (o['customer_phone'], o['table_id'], time_key)
        
        if key not in grouped_history:
            grouped_history[key] = []
        grouped_history[key].append(o)

    # Sort grouped keys by time descending
    sorted_keys = sorted(grouped_history.keys(), key=lambda x: x[2], reverse=True)

    for key in sorted_keys:
        items = grouped_history[key]
        first_item = items[0]
        
        card = tk.Frame(scroll_content, bg="white", bd=1, relief="solid", padx=8, pady=4)
        card.pack(fill="x", pady=2)
        
        # Header Info
        header_f = tk.Frame(card, bg="white")
        header_f.pack(fill="x")
        
        cust_name = first_item.get('customer_name', 'Bilinmeyen')
        cust_phone = first_item.get('customer_phone', '')
        time_str = first_item.get('created_at', '')
        
        title_text = f"👤 {cust_name}"
        if cust_phone: title_text += f" | 📞 {cust_phone}"
        
        tk.Label(header_f, text=title_text, font=("Arial", 12, "bold"), bg="white", fg="#333").pack(side="left")
        tk.Label(header_f, text=time_str, font=("Arial", 10), bg="white", fg="#666").pack(side="right")
        
        # Total
        total_price = sum(i['price'] * i['quantity'] for i in items)
        tk.Label(card, text=f"Toplam Tutar: {total_price:.2f} TL", font=("Arial", 11, "bold"), bg="white", fg="#2ecc71").pack(anchor="w", pady=(1, 3))
        
        # Address & Note
        addr = first_item.get('customer_address', '')
        if addr:
            tk.Label(card, text=f"📍 Adres: {addr}", font=("Arial", 10), bg="white", fg="#555", wraplength=800, justify="left").pack(anchor="w")
            
        note = first_item.get('note', '')
        if note:
            tk.Label(card, text=f"📝 Not: {note}", font=("Arial", 10, "italic"), bg="white", fg="#e67e22").pack(anchor="w")

        # Items Table
        items_frame = tk.Frame(card, bg="#f9f9f9", padx=5, pady=2)
        items_frame.pack(fill="x", pady=2)
        
        for item in items:
            row = tk.Frame(items_frame, bg="#f9f9f9")
            row.pack(fill="x")
            tk.Label(row, text=f"• {item['product_name']}", font=("Arial", 11), bg="#f9f9f9").pack(side="left")
            tk.Label(row, text=f"x{item['quantity']}", font=("Arial", 10, "bold"), bg="#f9f9f9", fg="#666").pack(side="left", padx=5)
            tk.Label(row, text=f"{item['price'] * item['quantity']:.2f} TL", font=("Arial", 10), bg="#f9f9f9", fg="#333").pack(side="right")

        # Delete from History (Optional)
        def delete_history_entry(customer_phone=key[0], table_id=key[1], time_prefix=key[2]):
            if messagebox.askyesno("Onay", "Bu geçmiş kaydını tamamen silmek istediğinize emin misiniz?"):
                # Note: We don't have a single call for this, we'll need a range delete or specific IDs
                # For safety, let's just warn it's not implemented or do a loop delete
                conn = data_manager.get_db_connection()
                conn.execute("DELETE FROM orders WHERE customer_phone = ? AND table_id = ? AND created_at LIKE ?", 
                             (customer_phone, table_id, f"{time_prefix}%"))
                conn.commit()
                conn.close()
                show_order_history_screen(user_phone, shop_name)

        tk.Button(card, text="Kaydı Sil", font=("Arial", 9), bg="white", fg="#e74c3c", bd=0, cursor="hand2", 
                  command=delete_history_entry).pack(side="right", pady=1)
