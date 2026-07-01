import re

with open('lib/presentation/common/cards/restaurant_card.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# The helper methods start at "  double _calculateDistance"
parts = content.split("  double _calculateDistance")
if len(parts) != 2:
    print("Could not find helper methods")
    exit(1)

helpers = "  double _calculateDistance" + parts[1]

# The top part ends at "  @override\n  Widget build(BuildContext context) {"
top_part = parts[0].split("  @override\n  Widget build(BuildContext context) {")[0]

new_build_method = """  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);
    final defaultAddress = addressProvider.defaultAddress;

    double? distance;
    if (res.latitude != null && res.longitude != null) {
      final userLat = defaultAddress?.latitude ?? 37.935;
      final userLng = defaultAddress?.longitude ?? 58.390;
      distance = _calculateDistance(userLat, userLng, res.latitude!, res.longitude!);
    }

    // Determine campaigns
    List<String> activeCampaigns = [];
    final resCampaigns = campaigns.where((c) => c.shopId == res.id || c.shopId == res.docId).toList();
    if (resCampaigns.isNotEmpty) {
      for (var c in resCampaigns) {
        activeCampaigns.add(c.title);
      }
    } else {
      double maxDiscount = 0;
      for (var food in res.menu) {
        if (food.isCampaign && food.oldPrice != null && food.oldPrice! > food.price) {
          double discount = ((food.oldPrice! - food.price) / food.oldPrice!) * 100;
          if (discount > maxDiscount) maxDiscount = discount;
        }
      }
      final lang = langProvider.selectedLang;
      if (maxDiscount > 0) {
        final percent = maxDiscount.toStringAsFixed(0);
        if (lang == 'TR') activeCampaigns.add("%$percent'e Varan İndirimler!");
        else if (lang == 'TM') activeCampaigns.add("%$percent-e çenli arzanlaşyk!");
        else activeCampaigns.add("Скидки до $percent%!");
      } else if (res.menu.any((f) => f.isCampaign)) {
        if (lang == 'TR') activeCampaigns.add("Kampanyalı Ürünler!");
        else if (lang == 'TM') activeCampaigns.add("Kampaniýaly önümler!");
        else activeCampaigns.add("Акционные товары!");
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(restaurant: res),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: HoverWrapper(
        child: Container(
          width: isCompact ? 280 : double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: res.isOpen
                        ? CachedNetworkImage(
                            imageUrl: res.imageUrl,
                            height: imageHeight ?? (isCompact ? 140 : 160),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: imageHeight ?? (isCompact ? 140 : 160),
                              color: AppColors.surfaceSubtle,
                              child: const Center(
                                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: imageHeight ?? (isCompact ? 140 : 160),
                              color: AppColors.surfaceSubtle,
                              child: const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 40),
                            ),
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: Opacity(
                              opacity: 0.6,
                              child: CachedNetworkImage(
                                imageUrl: res.imageUrl,
                                height: imageHeight ?? (isCompact ? 140 : 160),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  height: imageHeight ?? (isCompact ? 140 : 160),
                                  color: AppColors.surfaceSubtle,
                                  child: const Icon(Icons.fastfood_rounded, color: AppColors.textTertiary, size: 40),
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (!res.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              langProvider.get('shop_closed').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Campaign Chips (Top Left)
                  if (activeCampaigns.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: activeCampaigns.map((text) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD500),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_offer_rounded, color: Color(0xFF512DA8), size: 12),
                              const SizedBox(width: 4),
                              Text(
                                text,
                                style: GoogleFonts.inter(color: const Color(0xFF512DA8), fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                  // Distance Chip (Bottom Left)
                  if (distance != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.blueGrey, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              distance < 1.0 ? "${(distance * 1000).toStringAsFixed(0)} m" : "${distance.toStringAsFixed(1)} km",
                              style: GoogleFonts.inter(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Bottom Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name and Rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            res.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5), // Light purple bg
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFF512DA8), size: 14),
                              const SizedBox(width: 2),
                              Text(
                                "${res.rating} (1500+)", // Mocking the review count to match screenshot
                                style: GoogleFonts.inter(color: const Color(0xFF512DA8), fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Time, Min Order, Sponsorlu
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            "R",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${res.deliveryTime} • Min ${res.minOrderAmount.toStringAsFixed(0)} TMT",
                          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          "Sponsorlu",
                          style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

"""

new_content = top_part + "  @override\n  Widget build(BuildContext context) {\n" + new_build_method.split("  Widget build(BuildContext context) {\n")[1] + "\n" + helpers

with open('lib/presentation/common/cards/restaurant_card.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Updated restaurant_card.dart successfully.")
