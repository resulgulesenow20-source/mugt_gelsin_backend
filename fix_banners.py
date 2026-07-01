import os

def rewrite_banner_slider():
    with open('lib/pages/home/widgets/banner_slider.dart', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # 1. Update PageView.builder
    old_pageview = """        itemBuilder: (context, index) {
          final realIndex = index % totalCount;
          if (realIndex < campaigns.length) {
            return _buildCampaignItem(campaigns[realIndex], realIndex, totalCount);
          }
          final restaurantIndex = realIndex - campaigns.length;
          return _buildRestaurantBannerItem(featuredRestaurants[restaurantIndex], realIndex, totalCount);
        },"""

    new_pageview = """        itemBuilder: (context, index) {
          final realIndex = index % totalCount;
          Widget bannerItem;
          if (realIndex < campaigns.length) {
            bannerItem = _buildCampaignItem(campaigns[realIndex], realIndex, totalCount);
          } else {
            final restaurantIndex = realIndex - campaigns.length;
            bannerItem = _buildRestaurantBannerItem(featuredRestaurants[restaurantIndex], realIndex, totalCount);
          }

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                scale = _pageController.page! - index;
                scale = (1 - (scale.abs() * 0.15)).clamp(0.85, 1.0);
              } else {
                scale = _currentPage == index ? 1.0 : 0.85;
              }
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: bannerItem,
          );
        },"""
    
    content = content.replace(old_pageview, new_pageview)

    # 2. Remove AnimatedScale from _buildCampaignItem
    old_campaign_scale = """    return AnimatedScale(
      scale: (_currentPage % totalCount) == itemIndex ? 1.0 : 0.90,
      duration: const Duration(milliseconds: 500),
      child: Consumer<LanguageProvider>("""
    new_campaign_scale = """    return Consumer<LanguageProvider>("""
    content = content.replace(old_campaign_scale, new_campaign_scale)

    # Note: Because we removed AnimatedScale, the parenthesis count changed. We must remove the closing parenthesis of AnimatedScale at the end of the method.
    # Let's just do a manual string replace for the whole _buildCampaignItem if possible, but that's risky.
    # Instead, let's write a targeted function to fix the ends.

    old_campaign_end = """              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantBannerItem"""
    new_campaign_end = """              ],
            ),
          ),
        ),
    );
  }

  Widget _buildRestaurantBannerItem"""
    content = content.replace(old_campaign_end, new_campaign_end)

    # 3. Remove AnimatedScale from _buildRestaurantBannerItem
    old_restaurant_scale = """    return AnimatedScale(
      scale: (_currentPage % totalCount) == itemIndex ? 1.0 : 0.90,
      duration: const Duration(milliseconds: 500),
      child: Consumer<LanguageProvider>("""
    new_restaurant_scale = """    return Consumer<LanguageProvider>("""
    content = content.replace(old_restaurant_scale, new_restaurant_scale)

    old_restaurant_end = """              ],
            ),
          ),
        ),
      ),
    );
  }
}"""
    new_restaurant_end = """              ],
            ),
          ),
        ),
    );
  }
}"""
    content = content.replace(old_restaurant_end, new_restaurant_end)

    with open('lib/pages/home/widgets/banner_slider.dart', 'w', encoding='utf-8') as f:
        f.write(content)

rewrite_banner_slider()
