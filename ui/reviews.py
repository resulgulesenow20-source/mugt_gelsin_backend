import tkinter as tk
from tkinter import messagebox, scrolledtext
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager
import requests
import json
import threading
import time

API_BASE = "https://mugt-gelsin-backend-1.onrender.com/api/reviews"

def show_reviews_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Yorumlar - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Sağ Yan Menü (Sidebar)
    ui.utils.create_sidebar(ui.utils.root, shop_name, user_phone, "reviews")
    
    # Main Content Area
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="left", fill="both", expand=True)
    
    # Header with premium title
    header = tk.Frame(main_content, bg="white", height=90)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    title_frame = tk.Frame(header, bg="white")
    title_frame.pack(side="left", padx=40, pady=20)
    tk.Label(title_frame, text="⭐", font=("Inter", 22), bg="white").pack(side="left")
    
    text_f = tk.Frame(title_frame, bg="white")
    text_f.pack(side="left", padx=10)
    tk.Label(text_f, text="Müşteri Değerlendirmeleri", font=("Inter", 18, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w")
    tk.Label(text_f, text="Müşterilerinizin dükkanınız hakkındaki görüşleri", font=("Inter", 9), bg="white", fg=ui.utils.TEXT_DIM).pack(anchor="w")

    # Scrollable Container for Reviews
    container = tk.Frame(main_content, bg="#f5f5f5")
    container.pack(fill="both", expand=True, padx=30, pady=20)
    
    canvas = tk.Canvas(container, bg="#f5f5f5", highlightthickness=0)
    canvas.pack(side="left", fill="both", expand=True)
    
    scrollbar = tk.Scrollbar(container, orient="vertical", command=canvas.yview)
    scrollbar.pack(side="right", fill="y")
    
    canvas.configure(yscrollcommand=scrollbar.set)
    
    list_frame = tk.Frame(canvas, bg="#f5f5f5")
    canvas.create_window((0,0), window=list_frame, anchor="nw", width=800)
    
    def on_configure(event):
        canvas.configure(scrollregion=canvas.bbox("all"))
        canvas.itemconfig(1, width=event.width)
    
    canvas.bind('<Configure>', on_configure)

    def open_reply_modal(review_id, current_comment):
        modal = tk.Toplevel(ui.utils.root)
        modal.title("Cevap Yaz")
        modal.geometry("450x300")
        modal.configure(bg="white")
        
        tk.Label(modal, text="Yorum:", font=("Arial", 10, "bold"), bg="white").pack(anchor="w", padx=20, pady=(20,0))
        tk.Label(modal, text=current_comment, font=("Arial", 10, "italic"), bg="#f9f9f9", fg="#666", wraplength=400, justify="left", pady=10).pack(fill="x", padx=20)
        
        tk.Label(modal, text="Cevabınız:", font=("Arial", 10, "bold"), bg="white").pack(anchor="w", padx=20, pady=(10,0))
        entry = tk.Text(modal, font=("Arial", 12), height=4, bd=1, relief="solid")
        entry.pack(fill="x", padx=20, pady=5)
        
        def submit():
            txt = entry.get("1.0", tk.END).strip()
            if not txt: return
            try:
                resp = requests.post(f"{API_BASE}/reply", json={
                    "shop_id": "python_admin_1", # Hardcoded for now
                    "review_id": review_id,
                    "reply": txt
                })
                if resp.status_code == 200:
                    modal.destroy()
                    messagebox.showinfo("Başarılı", "Cevabınız kaydedildi.")
                    refresh_reviews()
            except: pass
            
        tk.Button(modal, text="GÖNDER", font=("Arial", 12, "bold"), bg="#5D3EBD", fg="white", pady=8, command=submit).pack(pady=20)

    def refresh_reviews():
        def task():
            try:
                # Use shop_id from settings/global if available, but for now matching the system
                shop_id = "python_admin_1"
                resp = requests.get(f"{API_BASE}/{shop_id}", timeout=5)
                if resp.status_code == 200:
                    reviews = resp.json()
                    ui.utils.root.after(0, lambda: _apply_ui(reviews))
            except: pass
            
        def _apply_ui(reviews):
            for widget in list_frame.winfo_children():
                widget.destroy()
                
            if not reviews:
                tk.Label(list_frame, text="Henüz yorum bulunmuyor.", font=("Arial", 14), bg="#f5f5f5", fg="#999").pack(pady=40)
                return
                
            for r in reviews:
                card = tk.Frame(list_frame, bg="white", highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR, padx=25, pady=20)
                card.pack(fill="x", pady=8)
                
                # Header: Name and Stars
                top_f = tk.Frame(card, bg="white")
                top_f.pack(fill="x")
                
                name_lbl = tk.Label(top_f, text=r.get("customerName", "Müşteri"), font=("Arial", 14, "bold"), bg="white", fg="#333")
                name_lbl.pack(side="left")
                
                stars = "⭐" * int(r.get("rating", 0))
                tk.Label(top_f, text=stars, font=("Arial", 12), bg="white", fg="#f1c40f").pack(side="left", padx=10)
                
                tk.Label(top_f, text=r.get("date", ""), font=("Arial", 10), bg="white", fg="#999").pack(side="right")
                
                # Comment
                tk.Label(card, text=r.get("comment", ""), font=("Arial", 12), bg="white", fg="#444", wraplength=700, justify="left", pady=10).pack(anchor="w")
                
                # Reply section
                reply = r.get("reply")
                if reply:
                    reply_f = tk.Frame(card, bg="#f0f0ff", padx=15, pady=10)
                    reply_f.pack(fill="x", pady=(5,0))
                    tk.Label(reply_f, text="Cevabınız:", font=("Arial", 10, "bold"), bg="#f0f0ff", fg="#5D3EBD").pack(anchor="w")
                    tk.Label(reply_f, text=reply, font=("Arial", 11), bg="#f0f0ff", fg="#333", wraplength=650, justify="left").pack(anchor="w")
                    
                    if r.get("replyDate"):
                        tk.Label(reply_f, text=r.get("replyDate"), font=("Arial", 9), bg="#f0f0ff", fg="#999").pack(anchor="e")
                else:
                    btn = tk.Button(card, text="💬 Cevapla", font=("Inter", 10, "bold"), bg=ui.utils.NAV_ACTIVE_LIGHT, fg=ui.utils.NAV_ACTIVE, bd=0, padx=20, pady=8, cursor="hand2",
                             command=lambda rid=r['id'], comm=r['comment']: open_reply_modal(rid, comm))
                    btn.pack(anchor="e")
                    ui.utils.add_hover_effect(btn, "#FFEFD5", ui.utils.NAV_ACTIVE_LIGHT)

        threading.Thread(target=task, daemon=True).start()

    # Start Polling
    def poll():
        # Only poll if still on reviews screen
        if hasattr(ui.utils, "current_page") and ui.utils.current_page == "reviews":
            refresh_reviews()
            ui.utils.root.after(10000, poll) # 10 seconds refresh for reviews

    ui.utils.current_page = "reviews"
    refresh_reviews()
    # poll() # Start polling if needed, but refresh_reviews once is usually enough on enter
    # Actually, let's enable polling but with longer interval
    poll()
