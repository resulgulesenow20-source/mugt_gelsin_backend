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
    
    # Sağ Yan Menü (Sidebar)
    ui.utils.create_sidebar(ui.utils.root, shop_name, user_phone, "menu")
    
    # Main Content Area
    main_content = tk.Frame(ui.utils.root, bg=ui.utils.bg_main)
    main_content.pack(side="left", fill="both", expand=True)
    
    # Header with premium title and stats summary
    header = tk.Frame(main_content, bg="white", height=100)
    header.pack(fill="x")
    header.pack_propagate(False)
    
    title_frame = tk.Frame(header, bg="white")
    title_frame.pack(side="left", padx=40, pady=25)
    tk.Label(title_frame, text="🍴", font=("Inter", 24), bg="white").pack(side="left")
    
    text_f = tk.Frame(title_frame, bg="white")
    text_f.pack(side="left", padx=10)
    tk.Label(text_f, text="Menü Yönetimi", font=("Inter", 20, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w")
    tk.Label(text_f, text="Ürünlerinizi yönetin ve yeni lezzetler ekleyin", font=("Inter", 11), bg="white", fg=ui.utils.TEXT_DIM).pack(anchor="w", pady=(2, 0))
    
    # Add Button (Modern Premium)
    add_btn = tk.Button(header, text="+ Yeni Ürün Ekle", font=("Inter", 10, "bold"), 
                        bg=ui.utils.ACCENT_GREEN, fg="white", activebackground="#00A884", activeforeground="white",
                        padx=30, pady=12, bd=0, cursor="hand2", 
                        command=lambda: open_menu_modal(user_phone, shop_name))
    add_btn.pack(side="right", padx=40)
    ui.utils.add_hover_effect(add_btn, "#00A884", ui.utils.ACCENT_GREEN)
    
    # Filter Bar (Professional Layout)
    filter_bar = tk.Frame(main_content, bg=ui.utils.bg_main)
    filter_bar.pack(fill="x", padx=40, pady=(25, 0))
    
    # Search (Modern Integrated Look)
    search_container = tk.Frame(filter_bar, bg="white", padx=15, pady=5)
    search_container.pack(side="left")
    
    # Rounded look simulation with padding
    search_inner = tk.Frame(search_container, bg="#f1f2f6", padx=10, pady=5)
    search_inner.pack()
    
    tk.Label(search_inner, text="🔍", font=("Arial", 12), bg="#f1f2f6", fg=ui.utils.TEXT_DIM).pack(side="left")
    _search_var = tk.StringVar()
    _search_var.trace_add("write", lambda *args: _setup_menu_list(content, user_phone, shop_name))
    
    search_entry = tk.Entry(search_inner, textvariable=_search_var, font=("Arial", 12), width=35, 
                            bd=0, bg="#f1f2f6", fg=ui.utils.TEXT_MAIN, insertbackground=ui.utils.TEXT_MAIN)
    search_entry.pack(side="left", padx=10)
    
    # Category Filter (Pill Style)
    cat_frame = tk.Frame(filter_bar, bg=ui.utils.bg_main)
    cat_frame.pack(side="left", padx=(30, 0))
    
    tk.Label(cat_frame, text="Kategoriler:", font=("Arial", 11, "bold"), bg=ui.utils.bg_main, fg=ui.utils.TEXT_DIM).pack(side="left", padx=(0, 15))
    
    categories = ["Tümü", "Ana Yemekler", "Ara Sıcaklar", "İçecekler", "Tatlılar", "Diğer"]
    for cat in categories:
        is_active = (_category_filter == cat)
        btn = tk.Button(cat_frame, text=cat, font=("Inter", 10, "bold" if is_active else "normal"),
                        bg=ui.utils.BRAND_COLOR if is_active else "white",
                        fg="white" if is_active else ui.utils.TEXT_MAIN,
                        padx=20, pady=10, bd=0, cursor="hand2", relief="flat")
        btn.configure(command=lambda c=cat: _set_cat_filter(c, content, user_phone, shop_name))
        btn.pack(side="left", padx=5)
        if not is_active:
            ui.utils.add_hover_effect(btn, "#F5F5F5", "white")

    content = tk.Frame(main_content, bg=ui.utils.bg_main)
    content.pack(fill="both", expand=True, padx=40, pady=(20, 40))
    
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
    canvas = tk.Canvas(parent, bg=ui.utils.bg_main, highlightthickness=0)
    canvas.pack(side="left", fill="both", expand=True)
    
    scroll = tk.Scrollbar(parent, orient="vertical", command=canvas.yview)
    scroll.pack(side="right", fill="y")
    
    canvas.configure(yscrollcommand=scroll.set)
    
    list_frame = tk.Frame(canvas, bg=ui.utils.bg_main)
    canvas.create_window((0,0), window=list_frame, anchor="nw", width=1050)
    
    def on_configure(event):
        canvas.configure(scrollregion=canvas.bbox("all"))
        canvas.itemconfig(1, width=event.width)
    
    canvas.bind('<Configure>', on_configure)

    # Mouse Wheel Support
    def _on_mousewheel(event):
        canvas.yview_scroll(int(-1*(event.delta/120)), "units")
        
    canvas.bind_all("<MouseWheel>", _on_mousewheel)

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
         tk.Label(list_frame, text="Uygun ürün bulunamadı.", font=("Arial", 18), bg=ui.utils.bg_main, fg=ui.utils.TEXT_DIM).pack(pady=100)
         return

    # Grid Layout for cards (3-4 columns depending on width)
    grid_container = tk.Frame(list_frame, bg=ui.utils.bg_main)
    grid_container.pack(fill="both", expand=True, pady=10)
    
    col = 0
    row = 0
    for item in filtered_items:
        _create_product_card(grid_container, item, user_phone, shop_name).grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        col += 1
        if col > 3:
            col = 0
            row += 1

def _create_product_card(parent, item, user_phone, shop_name):
    # Modern card with soft border and cleaner spacing
    card = tk.Frame(parent, bg="white", highlightthickness=1, highlightbackground=ui.utils.BORDER_COLOR)
    
    def on_enter(e):
        card.config(highlightbackground=ui.utils.NAV_ACTIVE)
    def on_leave(e):
        card.config(highlightbackground=ui.utils.BORDER_COLOR)
        
    card.bind("<Enter>", on_enter)
    card.bind("<Leave>", on_leave)

    # Image Area
    img_frame = tk.Frame(card, bg="#f8f9fa", height=140)
    img_frame.pack(fill="x")
    img_frame.pack_propagate(False)
    
    img_path = item.get('image_path')
    if img_path and os.path.exists(img_path):
        try:
            pil_img = Image.open(img_path)
            # Daha modern kart oranı 
            pil_img = pil_img.resize((260, 140), Image.Resampling.LANCZOS)
            photo = ImageTk.PhotoImage(pil_img)
            lbl_img = tk.Label(img_frame, image=photo, bg="#f8f9fa")
            lbl_img.image = photo 
            lbl_img.pack(fill="both", expand=True)
            lbl_img.bind("<Enter>", on_enter) # Propagate hover
        except:
            tk.Label(img_frame, text=item['icon'], font=("Arial", 40), bg="#f8f9fa").pack(expand=True)
    else:
        tk.Label(img_frame, text=item['icon'], font=("Arial", 40), bg="#f8f9fa").pack(expand=True)
    
    # Info Area
    info = tk.Frame(card, bg="white", padx=15, pady=12)
    info.pack(fill="both", expand=True)
    info.bind("<Enter>", on_enter)
    
    tk.Label(info, text=item['name'], font=("Arial", 13, "bold"), bg="white", fg=ui.utils.TEXT_MAIN).pack(anchor="w")
    
    cat_tag = tk.Label(info, text=item.get('category', 'Diğer'), font=("Arial", 8, "bold"), 
                       bg="#f1f2f6", fg=ui.utils.TEXT_DIM, padx=8, pady=3)
    cat_tag.pack(anchor="w", pady=5)
    
    desc = item['description']
    short_desc = desc[:60] + "..." if len(desc) > 60 else desc
    tk.Label(info, text=short_desc, font=("Arial", 10), bg="white", fg=ui.utils.TEXT_DIM, 
             wraplength=220, justify="left").pack(anchor="w", pady=(2, 10))
    
    # Footer
    footer = tk.Frame(info, bg="white")
    footer.pack(fill="x", side="bottom")
    footer.bind("<Enter>", on_enter)
    
    # Fiyat Etiketi (Premium Look)
    price_lbl = tk.Label(footer, text=f"{item['price']} TL", font=("Arial", 14, "bold"), bg="white", fg=ui.utils.ACCENT_GREEN)
    price_lbl.pack(side="left")
    
    actions = tk.Frame(footer, bg="white")
    actions.pack(side="right")
    
    edit_btn = tk.Button(actions, text="✏️", font=("Arial", 10), bg="#f1c40f", fg="white", bd=0, padx=8, pady=4, cursor="hand2",
                         command=lambda i=item: open_menu_modal(user_phone, shop_name, i))
    edit_btn.pack(side="left", padx=3)
    ui.utils.add_hover_effect(edit_btn, "#f39c12", "#f1c40f")
              
    del_btn = tk.Button(actions, text="🗑️", font=("Arial", 10), bg=ui.utils.BRAND_COLOR, fg="white", bd=0, padx=8, pady=4, cursor="hand2",
                        command=lambda id=item['id']: delete_item(id, user_phone, shop_name))
    del_btn.pack(side="left", padx=3)
    ui.utils.add_hover_effect(del_btn, "#c0392b", ui.utils.BRAND_COLOR)
    
    # Stock badge (Premium overlapping style)
    stock = item.get('stock', 0)
    stock_color = ui.utils.NAV_ACTIVE if stock < 5 else ui.utils.ACCENT_GREEN
    stock_badge = tk.Label(card, text=f"Stok: {stock}", font=("Inter", 8, "bold"), bg=stock_color, fg="white", padx=10, pady=4)
    stock_badge.place(x=10, y=10)
    
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
            
    tk.Button(img_row, text="Seç", command=pick_image, bg=ui.utils.NAV_ACTIVE, fg="white", bd=0, padx=10).pack(side="left", padx=5)

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
            icon = e_icon.get().strip()
            name = e_name.get().strip()
            desc = e_desc.get().strip()
            category = e_category.get()
            image_path = img_path_var.get()
            
            # Stock validation
            stock_raw = e_stock.get().strip()
            try:
                stock = int(stock_raw)
            except ValueError:
                messagebox.showerror("Hata", f"Stok adedi tam sayı olmalıdır: '{stock_raw}'")
                return

            # Price validation (handle comma and dot)
            price_raw = e_price.get().strip().replace(',', '.')
            try:
                price = float(price_raw)
            except ValueError:
                messagebox.showerror("Hata", f"Fiyat geçerli bir sayı olmalıdır: '{price_raw}'")
                return
            
            if not name:
                messagebox.showwarning("Hata", "Ürün adı boş olamaz.")
                return

            if item:
                data_manager.update_menu_item(user_phone, item['id'], icon, name, desc, price, stock, category, image_path)
            else:
                data_manager.add_menu_item(user_phone, icon, name, desc, price, stock, category, image_path)

            modal.destroy()
            show_menu_screen(user_phone, shop_name)
            
        except Exception as e:
            import traceback
            error_details = traceback.format_exc()
            print(f"DEBUG: Save error: {error_details}")
            messagebox.showerror("Sistem Hatası", f"Kaydetme sırasında bir hata oluştu:\n{e}")

    tk.Button(modal, text="KAYDET", command=save, bg="#00b894", fg="white", font=("Arial", 16, "bold"), 
              pady=12, width=30, bd=0, cursor="hand2").pack(pady=30)
