import os

def tweak_banner_visual3():
    with open('lib/pages/home/widgets/banner_slider.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Change viewportFraction from 0.85 to 0.78 to show even more of the side banners
    content = content.replace("viewportFraction: 0.85", "viewportFraction: 0.78")

    with open('lib/pages/home/widgets/banner_slider.dart', 'w', encoding='utf-8') as f:
        f.write(content)

tweak_banner_visual3()
