import os
import sys
from PIL import Image

def optimize_images(directory, max_size_kb=50, max_dim=500):
    total_saved = 0
    count = 0
    
    for root, dirs, files in os.walk(directory):
        for f in files:
            if not f.lower().endswith(('.png', '.jpg', '.jpeg')):
                continue
                
            path = os.path.join(root, f)
            original_size = os.path.getsize(path)
            
            if original_size < max_size_kb * 1024:
                continue
                
            try:
                img = Image.open(path)
                
                # Resize if larger than max_dim
                if img.width > max_dim or img.height > max_dim:
                    img.thumbnail((max_dim, max_dim), Image.Resampling.LANCZOS)
                
                # Check transparency
                has_alpha = False
                if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
                    has_alpha = True
                
                if has_alpha:
                    # Check if alpha is fully opaque
                    alpha = img.convert('RGBA').split()[-1]
                    if alpha.getextrema()[0] == 255:
                        has_alpha = False
                
                out_format = 'PNG' if has_alpha else 'JPEG'
                
                if has_alpha:
                    img.save(path, format='PNG', optimize=True)
                else:
                    img = img.convert('RGB')
                    img.save(path, format='JPEG', quality=85)
                    
                new_size = os.path.getsize(path)
                saved = original_size - new_size
                if saved > 0:
                    total_saved += saved
                    count += 1
                    print(f"Compressed {f}: {original_size/1024:.1f} KB -> {new_size/1024:.1f} KB (Saved {saved/1024:.1f} KB)")
                
            except Exception as e:
                print(f"Error processing {f}: {e}")
                
    print(f"\nTotal images optimized: {count}")
    print(f"Total space saved: {total_saved / (1024*1024):.2f} MB")

if __name__ == "__main__":
    target_dir = r"c:\Users\dell\mugut_gelsin\assets\images"
    optimize_images(target_dir)
