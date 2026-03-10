import tkinter as tk
from tkinter import messagebox, filedialog
from PIL import Image, ImageTk
import os
import ui.utils
from ui.utils import clear_window, create_top_nav_bar
import data_manager_sqlite as data_manager

_search_var = None
_category_filter = "Tümü"

def show_menu_screen(user_phone, shop_name):
    global _search_var, _category_filter
    clear_window()
    ui.utils.root.title(f"Menü Yönetimi - {shop_name}")
    ui.utils.root.geometry("1100x700")
    ui.utils.root.configure(bg="#f5f5f5")
    
    # Üst Navigasyon
    ui.utils.create_top_nav_bar(ui.utils.root, shop_name, user_phone, "menu")
    
    # Main Content
    main_content = tk.Frame(ui.utils.root, bg="#f8f9fa")
    main_content.pack(side="right", fill="both", expand=True)
    
    # Header
    header = tk.Frame(main_content, bg="white", height=80)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    tk.Label(header, text="🍴 Menü Yönetimi", font=("Arial", 28, "bold"), bg="white", fg="#2d3436").pack(side="left", padx=40, pady=20)
    
    # Add Button
    tk.Button(header, text="+ Yeni Ürün Ekle", font=("Arial", 14, "bold"), bg="#00b894", fg="white", 
              padx=20, pady=10, bd=0, cursor="hand2", 
              command=lambda: open_menu_modal(user_phone, shop_name)).pack(side="right", padx=40)
    
    # Filter Bar
    filter_bar = tk.Frame(main_content, bg="#f8f9fa")
    filter_bar.pack(fill="x", padx=40, pady=(20, 10))
    
    # Search
    search_frame = tk.Frame(filter_bar, bg="white", bd=1, relief="solid")
    search_frame.pack(side="left")
    
    tk.Label(search_frame, text="🔍", font=("Arial", 14), bg="white").pack(side="left", padx=10)
    _search_var = tk.StringVar()
    _search_var.trace_add("write", lambda *args: _setup_menu_list(content, user_phone, shop_name))
    tk.Entry(search_frame, textvariable=_search_var, font=("Arial", 14), width=30, bd=0).pack(side="left", padx=10, pady=8)
    
    # Category Filter
    tk.Label(filter_bar, text="Kategori:", font=("Arial", 12, "bold"), bg="#f8f9fa", fg="#636e72").pack(side="left", padx=(30, 10))
    
    categories = ["Tümü", "Ana Yemekler", "Ara Sıcaklar", "İçecekler", "Tatlılar", "Diğer"]
    for cat in categories:
        btn = tk.Button(filter_bar, text=cat, font=("Arial", 11, "bold" if _category_filter == cat else "normal"),
                        bg="#6c5ce7" if _category_filter == cat else "white",
                        fg="white" if _category_filter == cat else "#2d3436",
                        padx=15, pady=5, bd=0, cursor="hand2")
        btn.configure(command=lambda c=cat: _set_cat_filter(c, content, user_phone, shop_name))
        btn.pack(side="left", padx=5)

    content = tk.Frame(main_content, bg="#f8f9fa")
    content.pack(fill="both", expand=True, padx=40, pady=10)
    
    # Menu List
    _setup_menu_list(content, user_phone, shop_name)

def _set_cat_filter(cat, content, user_phone, shop_name):
    global _category_filter
    _category_filter = cat
    # Re-show to update button styles
    show_menu_screen(user_phone, shop_name)

def _setup_menu_list(parent, user_phone, shop_name):
    # Clear previous list
    for widget in parent.winfo_children():
        widget.destroy()

    # Scrollable area
    canvas = tk.Canvas(parent, bg="#f8f9fa", highlightthickness=0)
    canvas.pack(side="left", fill="both", expand=True)
    
    scroll = tk.Scrollbar(parent, orient="vertical", command=canvas.yview)
    scroll.pack(side="right", fill="y")
    
    canvas.configure(yscrollcommand=scroll.set)
    
    list_frame = tk.Frame(canvas, bg="#f8f9fa")
    canvas.create_window((0,0), window=list_frame, anchor="nw", width=1050)
    
    def on_configure(event):
        canvas.configure(scrollregion=canvas.bbox("all"))
        canvas.itemconfig(1, width=event.width)
    
    canvas.bind('<Configure>', on_configure)

    menu_items = data_manager.get_menu_items()
    
    # Apply filters
    search_q = _search_var.get().lower() if _search_var else ""
    filtered_items = []
    for item in menu_items:
        if _category_filter != "Tümü" and item.get('category') != _category_filter:
            continue
        if search_q and search_q not in item['name'].lower() and search_q not in item.get('description', '').lower():
            continue
        filtered_items.append(item)

    if not filtered_items:
         tk.Label(list_frame, text="Uygun ürün bulunamadı.", font=("Arial", 18), bg="#f8f9fa", fg="#999").pack(pady=100)
         return

    # Grid Layout for cards (3 columns)
    grid_container = tk.Frame(list_frame, bg="#f8f9fa")
    grid_container.pack(fill="both", expand=True)
    
    col = 0
    row = 0
    for item in filtered_items:
        _create_product_card(grid_container, item, user_phone, shop_name).grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        col += 1
        if col > 3:
            col = 0
            row += 1

def _create_product_card(parent, item, user_phone, shop_name):
    card = tk.Frame(parent, bg="white", bd=0, relief="flat", highlightthickness=1, highlightbackground="#dfe6e9")
    
    # Image Area
    img_frame = tk.Frame(card, bg="#f1f2f6", height=120)
    img_frame.pack(fill="x")
    img_frame.pack_propagate(False)
    
    img_path = item.get('image_path')
    if img_path and os.path.exists(img_path):
        try:
            pil_img = Image.open(img_path)
            pil_img = pil_img.resize((240, 120), Image.Resampling.LANCZOS)
            photo = ImageTk.PhotoImage(pil_img)
            lbl_img = tk.Label(img_frame, image=photo, bg="#f1f2f6")
            lbl_img.image = photo # keep reference
            lbl_img.pack(fill="both", expand=True)
        except:
            tk.Label(img_frame, text=item['icon'], font=("Arial", 32), bg="#f1f2f6").pack(expand=True)
    else:
        tk.Label(img_frame, text=item['icon'], font=("Arial", 32), bg="#f1f2f6").pack(expand=True)
    
    # Info Area
    info = tk.Frame(card, bg="white", padx=10, pady=8)
    info.pack(fill="both", expand=True)
    
    tk.Label(info, text=item['name'], font=("Arial", 12, "bold"), bg="white", fg="#2d3436").pack(anchor="w")
    
    cat_lbl = tk.Label(info, text=item.get('category', 'Diğer'), font=("Arial", 9, "bold"), 
                       bg="#dfe6e9", fg="#636e72", padx=6, pady=2)
    cat_lbl.pack(anchor="w", pady=2)
    
    desc = item['description']
    tk.Label(info, text=desc[:50] + "..." if len(desc) > 50 else desc, 
             font=("Arial", 10), bg="white", fg="#636e72", wraplength=220, justify="left").pack(anchor="w", pady=(2, 5))
    
    # Footer
    footer = tk.Frame(info, bg="white")
    footer.pack(fill="x", side="bottom")
    
    tk.Label(footer, text=f"{item['price']} TL", font=("Arial", 14, "bold"), bg="white", fg="#2ecc71").pack(side="left")
    
    actions = tk.Frame(footer, bg="white")
    actions.pack(side="right")
    
    tk.Button(actions, text="✏️", font=("Arial", 10), bg="#f1c40f", fg="white", bd=0, padx=6, pady=2, cursor="hand2",
              command=lambda i=item: open_menu_modal(user_phone, shop_name, i)).pack(side="left", padx=2)
              
    tk.Button(actions, text="🗑️", font=("Arial", 10), bg="#e74c3c", fg="white", bd=0, padx=6, pady=2, cursor="hand2",
              command=lambda id=item['id']: delete_item(id, user_phone, shop_name)).pack(side="left", padx=2)
    
    # Stock badge
    stock = item.get('stock', 0)
    stock_color = "#e17055" if stock < 5 else "#00b894"
    tk.Label(card, text=f"Stok: {stock}", font=("Arial", 9, "bold"), bg=stock_color, fg="white", padx=6, pady=2).place(x=5, y=5)
    
    return card

def delete_item(item_id, user_phone, shop_name):
    if messagebox.askyesno("Sil", "Bu ürünü silmek istediğinize emin misiniz?"):
        data_manager.delete_menu_item(user_phone, item_id)
        show_menu_screen(user_phone, shop_name)

def open_menu_modal(user_phone, shop_name, item=None):
    modal = tk.Toplevel(ui.utils.root)
    modal.title("Ürün Düzenle" if item else "Yeni Ürün Ekle")
    modal.geometry("500x700")
    modal.configure(bg="white")
    modal.transient(ui.utils.root)
    modal.grab_set()
    
    tk.Label(modal, text="📦 Ürün Bilgileri", font=("Arial", 22, "bold"), bg="white", fg="#2d3436").pack(pady=20)
    
    form = tk.Frame(modal, bg="white", padx=40)
    form.pack(fill="both", expand=True)

    def create_input(label, value=""):
        tk.Label(form, text=label, bg="white", font=("Arial", 11, "bold"), fg="#636e72").pack(anchor="w", pady=(10,0))
        entry = tk.Entry(form, font=("Arial", 13), width=40, bd=1, relief="solid")
        entry.pack(pady=5, ipady=5)
        if value: entry.insert(0, value)
        return entry

    # Image Selector
    img_path_var = tk.StringVar(value=item.get('image_path', '') if item else '')
    
    tk.Label(form, text="Ürün Görseli:", bg="white", font=("Arial", 11, "bold"), fg="#636e72").pack(anchor="w", pady=(10,0))
    img_row = tk.Frame(form, bg="white")
    img_row.pack(fill="x", pady=5)
    
    tk.Entry(img_row, textvariable=img_path_var, font=("Arial", 10), state="readonly", width=30).pack(side="left")
    
    def pick_image():
        path = filedialog.askopenfilename(filetypes=[("Resim Dosyaları", "*.jpg *.png *.jpeg")])
        if path:
            img_path_var.set(path)
            
    tk.Button(img_row, text="Seç", command=pick_image, bg="#6c5ce7", fg="white", bd=0, padx=10).pack(side="left", padx=5)

    e_icon = create_input("İkon (Emoji):", item['icon'] if item else "🍔")
    e_name = create_input("Ürün Adı:", item['name'] if item else "")
    
    # Category Selection
    from tkinter import ttk
    tk.Label(form, text="Kategori:", bg="white", font=("Arial", 11, "bold"), fg="#636e72").pack(anchor="w", pady=(10,0))
    categories = ["Ana Yemekler", "Ara Sıcaklar", "İçecekler", "Tatlılar", "Diğer"]
    e_category = ttk.Combobox(form, values=categories, font=("Arial", 13), state="readonly", width=38)
    e_category.pack(pady=5)
    e_category.set(item.get('category', 'Diğer') if item else "Ana Yemekler")
    
    e_desc = create_input("Açıklama:", item['description'] if item else "")
    e_stock = create_input("Stok Adedi:", str(item.get('stock', 0)) if item else "0")
    e_price = create_input("Fiyat (TL):", str(item['price']) if item else "")

    def save():
        try:
            icon = e_icon.get()
            name = e_name.get()
            desc = e_desc.get()
            stock = int(e_stock.get())
            price = float(e_price.get())
            category = e_category.get()
            image_path = img_path_var.get()
            
            if not name:
                messagebox.showwarning("Hata", "Ürün adı boş olamaz.")
                return

            if item:
                data_manager.update_menu_item(user_phone, item['id'], icon, name, desc, price, stock, category, image_path)
            else:
                data_manager.add_menu_item(user_phone, icon, name, desc, price, stock, category, image_path)

            modal.destroy()
            show_menu_screen(user_phone, shop_name)
            
        except ValueError:
             messagebox.showerror("Hata", "Stok ve Fiyat sayısal olmalıdır.")
        except Exception as e:
             import traceback
             error_details = traceback.format_exc()
             print(f"DEBUG: Save error: {error_details}")
             messagebox.showerror("Sistem Hatası", f"Kaydetme sırasında bir hata oluştu:\n{e}")

    tk.Button(modal, text="KAYDET", command=save, bg="#00b894", fg="white", font=("Arial", 16, "bold"), 
              pady=12, width=30, bd=0, cursor="hand2").pack(pady=30)
