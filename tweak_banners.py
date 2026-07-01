import os

def tweak_banner():
    with open('lib/pages/home/widgets/banner_slider.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # Change viewportFraction to 0.82 to show more of the side banners
    content = content.replace("viewportFraction: 0.88", "viewportFraction: 0.82")

    # Increase the scale animation intensity so they grow/shrink more noticeably
    content = content.replace("scale = (1 - (scale.abs() * 0.15)).clamp(0.85, 1.0);", "scale = (1 - (scale.abs() * 0.25)).clamp(0.75, 1.0);")
    content = content.replace("scale = _currentPage == index ? 1.0 : 0.85;", "scale = _currentPage == index ? 1.0 : 0.75;")

    # Decrease horizontal margin inside the banner item to let the viewportFraction do the spacing work
    content = content.replace("margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),", "margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),")

    with open('lib/pages/home/widgets/banner_slider.dart', 'w', encoding='utf-8') as f:
        f.write(content)

tweak_banner()
