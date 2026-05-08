import '../models/restaurant_model.dart';
import '../models/category_model.dart';

final List<Category> dummyCategories = [
  Category(name: "Burger", imageUrl: "assets/images/cat_burger.png"),
  Category(name: "Pizza", imageUrl: "assets/images/cat_pizza.png"),
  Category(name: "Kebap", imageUrl: "assets/images/cat_kebap.png"),
  Category(name: "Tatlı", imageUrl: "assets/images/cat_dessert.png"),
  Category(name: "Deniz Ürünü", imageUrl: "assets/images/cat_seafood.png"),
];

final List<Restaurant> dummyRestaurants = [
  Restaurant(
    id: "python_admin_1",
    name: "mugut_Gelsin Ana Dükkan",
    imageUrl: "https://images.unsplash.com/photo-1551632811-561732d1e306?w=500",
    rating: "5.0",
    deliveryTime: "0-5 dk",
    category: "Admin",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "special_burger",
        name: "ðŸ” Özel Burger",
        description: "Acılı sos ile",
        price: 245.0,
        imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
      ),
      Food(
        id: "_karışık_pizza",
        name: "ðŸ• Karışık Pizza",
        description: "Ekstra peynir",
        price: 310.0,
        imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400",
      ),
    ],
  ),
  Restaurant(
    id: "1",
    name: "Lezzet Pizza",
    imageUrl: "assets/images/gamburger1.png",
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Pizza",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "margarita",
        name: "Margarita",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tayar_manti",
        name: "tayar manti",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tayar_tovuk",
        name: "tayar tovuk",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "margarita",
        name: "Margarita",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "margarita",
        name: "Margarita",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "margarita",
        name: "Margarita",
        description: "Bol peynirli, taze domates soslu",
        price: 120.0,
        imageUrl: "assets/images/hatay_doner.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "karışık_pizza",
        name: "Karışık Pizza",
        description: "Zengin malzeme seçeneğiyle",
        price: 150.0,
        imageUrl: "assets/images/pizzade.png",
        // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "2",
    name: "Doyum Burger",
    imageUrl: "assets/images/peynirli_burger.png",

    rating: "4.8",
    deliveryTime: "15-25 dk",
    category: "Burger",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "klasik_burger",
        name: "Klasik Burger",
        description: "Özel soslu dana köfte",
        price: 180.0,
        imageUrl: "assets/images/soslu_burger.png",
        // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "3",
    name: "Hatay Döner",
    imageUrl: "assets/images/hamburger.png",
    // âœ… RESTORAN RESMİ GÜNCELLENDİ
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Kebap",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "tavuk_döner",
        name: "Tavuk Döner",
        description: "Bol soslu Hatay usulü",
        price: 90.0,
        imageUrl: "assets/images/hamburger.png", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "4",
    name: "Popeyes",
    imageUrl:
        "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500", // âœ… TAVUK RESMİ
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Burger",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "maxi_menü",
        name: "Maxi Menü",
        description: "Çıtır tavuklar ve patates",
        price: 160.0,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "5",
    name: "Burger King",
    imageUrl:
        "https://images.unsplash.com/photo-1534422298391-e4f8c170db06?w=500",
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Burger",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "whopper",
        name: "Whopper",
        description: "Ateş seni çağırıyor",
        price: 210.0,
        imageUrl:
            "https://images.unsplash.com/photo-1536510233921-8e5043fce771?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "6",
    name: "İbrahim Dönerci",
    imageUrl:
        "https://images.unsplash.com/photo-1662116765994-1e03f0701c51?w=500",
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Kebap",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "et_döner",
        name: "Et Döner",
        description: "Yaprak döner",
        price: 140.0,
        imageUrl:
            "https://images.unsplash.com/photo-1633321702518-7feccaf0ad44?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "7",
    name: "Meva",
    imageUrl:
        "https://images.unsplash.com/photo-1551024601-bec78aea704b?w=500", // âœ… TATLI RESMİ
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Tatlı",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "baklava",
        name: "Baklava",
        description: "Gaziantep fıstıklı",
        price: 100.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "8",
    name: "Petra",
    imageUrl:
        "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500", // âœ… DENİZ ÜRÜNÜ RESMİ
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Deniz Ürünü",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "izgara_balık",
        name: "Izgara Balık",
        description: "Mevsim balığı, salata ile",
        price: 220.0,
        imageUrl:
            "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "9",
    name: "Pide Line",
    imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500",
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Kebap",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "kuşbaşılı_pide",
        name: "Kuşbaşılı Pide",
        description: "Çıtır kenarlı, bol malzemeli",
        price: 130.0,
        imageUrl:
            "https://images.unsplash.com/photo-1613564834644-a17af65e94b2?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
  Restaurant(
    id: "10",
    name: "Mertcan Döner",
    imageUrl:
        "https://images.unsplash.com/photo-1594007654729-407eedc4be65?w=500",
    rating: "4.5",
    deliveryTime: "20-30 dk",
    category: "Kebap",
    minOrderAmount: 50.0,
    menu: [
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
      Food(
        id: "gamburger",
        name: "Gamburger",
        description: "Ev yapımı köfte lezzeti",
        price: 120.0,
        imageUrl:
            "https://images.unsplash.com/photo-1550547660-d9450f859349?w=400", // âœ… GÜNCELLENDİ
      ),
    ],
  ),
];

