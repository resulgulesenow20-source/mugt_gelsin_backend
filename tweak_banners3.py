import os

def tweak_banner_visual2():
    with open('lib/pages/home/widgets/banner_slider.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Change viewportFraction to 0.85 to show a good chunk of the side banners
    content = content.replace("viewportFraction: 0.92", "viewportFraction: 0.85")

    # Adjust scale for unselected items to be 0.90 for a subtle effect
    content = content.replace("scale = (1 - (scale.abs() * 0.1)).clamp(0.92, 1.0);", "scale = (1 - (scale.abs() * 0.1)).clamp(0.90, 1.0);")
    content = content.replace("scale = _currentPage == index ? 1.0 : 0.92;", "scale = _currentPage == index ? 1.0 : 0.90;")

    # Adjust horizontal margin slightly
    content = content.replace("margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),", "margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),")

    # The user might be complaining about how restaurant banners look in the carousel. 
    # But they specifically said "sagından solundan gelen reklam gorunsun" (let the ads coming from left and right be visible).
    # So viewportFraction is the key here.

    with open('lib/pages/home/widgets/banner_slider.dart', 'w', encoding='utf-8') as f:
        f.write(content)

tweak_banner_visual2()
