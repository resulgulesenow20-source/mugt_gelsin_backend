import tkinter as tk
from tkinter import messagebox, scrolledtext
import ui.utils
from ui.utils import clear_window
import data_manager_sqlite as data_manager
import requests
import json
import threading
import time

API_BASE = "http://localhost:5000/api/support"

def show_customer_service_screen(user_phone, shop_name):
    clear_window()
    ui.utils.root.title(f"Müşteri Hizmetleri - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "support")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f5f5f5")
    main_content.pack(side="right", fill="both", expand=True)
    
    # Left Panel: Customer List
    left_panel = tk.Frame(main_content, bg="white", width=300, bd=1, relief="solid")
    left_panel.pack(side="left", fill="y")
    left_panel.pack_propagate(False)
    
    tk.Label(left_panel, text="📩 Mesajlar", font=("Arial", 16, "bold"), bg="white", pady=15).pack(fill="x")
    
    chat_list_frame = tk.Frame(left_panel, bg="white")
    chat_list_frame.pack(fill="both", expand=True)
    
    # Right Panel: Chat Window
    right_panel = tk.Frame(main_content, bg="#f5f5f5")
    right_panel.pack(side="right", fill="both", expand=True)
    
    chat_header = tk.Frame(right_panel, bg="white", height=60, bd=1, relief="flat")
    chat_header.pack(fill="x")
    chat_header.pack_propagate(False)
    
    selected_user_label = tk.Label(chat_header, text="Bir sohbet seçin", font=("Arial", 14, "bold"), bg="white")
    selected_user_label.pack(side="left", padx=20, pady=15)
    
    chat_display = scrolledtext.ScrolledText(right_panel, bg="#f5f5f5", font=("Arial", 12), state='disabled', bd=0)
    chat_display.pack(fill="both", expand=True, padx=20, pady=10)
    
    input_frame = tk.Frame(right_panel, bg="white", height=80, bd=1, relief="flat")
    input_frame.pack(fill="x", side="bottom")
    
    msg_entry = tk.Entry(input_frame, font=("Arial", 14), bd=0, highlightthickness=0)
    msg_entry.pack(side="left", fill="both", expand=True, padx=20, pady=20)
    
    current_selected_uid = [None] # Use list for mutability in nested functions
    
    def send_reply(event=None):
        uid = current_selected_uid[0]
        text = msg_entry.get().strip()
        if not uid or not text: return
        
        try:
            requests.post(f"{API_BASE}/message", json={
                "userUid": uid,
                "text": text,
                "sender": "restaurant",
                "shopName": shop_name
            })
            msg_entry.delete(0, tk.END)
            refresh_chat(uid)
        except: pass

    send_btn = tk.Button(input_frame, text="GÖNDER", font=("Arial", 12, "bold"), bg="#5D3EBD", fg="white",
                        padx=20, bd=0, cursor="hand2", command=send_reply)
    send_btn.pack(side="right", padx=20, pady=15)
    
    msg_entry.bind("<Return>", send_reply)

    def refresh_chat(uid):
        if not uid: return
        
        def task():
            try:
                resp = requests.get(f"{API_BASE}/messages/{uid}", timeout=5)
                if resp.status_code == 200:
                    messages = resp.json()
                    # Update UI in main thread
                    ui.utils.root.after(0, lambda: _apply_messages(messages))
            except Exception as e:
                print(f"Refresh chat error: {e}")

        def _apply_messages(messages):
            # Verify if still on the same chat
            if current_selected_uid[0] != uid: return
            
            chat_display.config(state='normal')
            chat_display.delete('1.0', tk.END)
            for msg in messages:
                prefix = "Mugt Destek: " if msg["sender"] == "admin" else "Siz: "
                color = "#333" if msg["sender"] == "admin" else "#5D3EBD"
                chat_display.insert(tk.END, f"{prefix}{msg['text']}\n", ("bold",))
                chat_display.insert(tk.END, f"{msg.get('timestamp', '')}\n\n")
            chat_display.see(tk.END)
            chat_display.config(state='disabled')

        threading.Thread(target=task, daemon=True).start()

    def select_chat(uid, name):
        current_selected_uid[0] = uid
        selected_user_label.config(text=f"👤 {name}")
        refresh_chat(uid)

    def update_chat_list():
        # Check if we are still on the support page
        if not hasattr(ui.utils, "current_page") or ui.utils.current_page != "support":
            return

        def task():
            try:
                resp = requests.get(f"{API_BASE}/chats/{user_phone}", timeout=5)
                if resp.status_code == 200:
                    chats = resp.json()
                    ui.utils.root.after(0, lambda: _apply_chat_list(chats))
            except Exception as e:
                print(f"Update chat list error: {e}")

        def _apply_chat_list(chats):
            # Only update if list size or content potentially changed (simple check)
            # For simplicity, we'll redraw but it's now in main thread and non-blocking
            
            # Clear frame
            for widget in chat_list_frame.winfo_children():
                widget.destroy()
            
            for chat in chats:
                uid = chat["userUid"]
                name = chat["userName"]
                last_msg = chat.get("lastMessage", "")
                
                bg_color = "#f0f0ff" if current_selected_uid[0] == uid else "white"
                
                btn = tk.Button(chat_list_frame, text=f"{name}\n{last_msg[:20]}...", 
                               font=("Arial", 10), bg=bg_color, anchor="w", justify="left",
                               relief="flat", pady=10, padx=15, cursor="hand2",
                               command=lambda u=uid, n=name: select_chat(u, n))
                btn.pack(fill="x")
                tk.Frame(chat_list_frame, bg="#eee", height=1).pack(fill="x")
            
            # Poll new messages if a chat is selected
            if current_selected_uid[0]:
                refresh_chat(current_selected_uid[0])

            # Schedule next update
            ui.utils.root.after(4000, update_chat_list)

        threading.Thread(target=task, daemon=True).start()

    # Start polling
    # Set current page tracking (ensure ui.utils supports it or it's added)
    ui.utils.current_page = "support"
    update_chat_list()
