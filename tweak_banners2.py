import os

def tweak_banner_again():
    with open('lib/pages/home/widgets/banner_slider.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update height from 180 to 210
    content = content.replace("height: 180,", "height: 210,")

    # 2. Update viewportFraction to 0.92 (less side visibility)
    content = content.replace("viewportFraction: 0.82", "viewportFraction: 0.92")

    # 3. Update scale math for a more subtle zoom
    content = content.replace("scale = (1 - (scale.abs() * 0.25)).clamp(0.75, 1.0);", "scale = (1 - (scale.abs() * 0.1)).clamp(0.92, 1.0);")
    content = content.replace("scale = _currentPage == index ? 1.0 : 0.75;", "scale = _currentPage == index ? 1.0 : 0.92;")

    # 4. Update horizontal margin
    content = content.replace("margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),", "margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),")

    with open('lib/pages/home/widgets/banner_slider.dart', 'w', encoding='utf-8') as f:
        f.write(content)

tweak_banner_again()
