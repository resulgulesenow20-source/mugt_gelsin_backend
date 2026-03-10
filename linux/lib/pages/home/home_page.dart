import 'package:flutter/material.dart';
import 'package:mugt_gelsin/utils/dummy_data.dart';
import 'package:mugt_gelsin/pages/home/widgets/category_list.dart';
import 'package:mugt_gelsin/models/restaurant_model.dart';
import 'package:mugt_gelsin/pages/home/widgets/restaurant_grid.dart';
import 'package:mugt_gelsin/pages/home/widgets/horizontal_restaurant_list.dart';
import 'package:mugt_gelsin/pages/favorites/favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Restaurant> displayedRestaurants = [];

  @override
  void initState() {
    super.initState();
    displayedRestaurants = List.from(dummyRestaurants);
  }

  void _filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedRestaurants = List.from(dummyRestaurants);
      } else {
        displayedRestaurants = dummyRestaurants
            .where(
              (res) => res.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _filterByCategory(String categoryName) {
    setState(() {
      if (categoryName == "Hepsi") {
        displayedRestaurants = List<Restaurant>.from(dummyRestaurants);
      } else {
        displayedRestaurants = dummyRestaurants
            .where(
              (res) => res.category.toLowerCase() == categoryName.toLowerCase(),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D3EBD),
        title: const Text(
          "mugt_gelsin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddressBar(),
            _buildSearchBar(),
            CategoryList(
              onCategorySelected: (category) => _filterByCategory(category),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Öne Çıkanlar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            HorizontalRestaurantList(restaurants: displayedRestaurants),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Restoranlar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            RestaurantGrid(restaurants: displayedRestaurants),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ARAMA ÇUBUĞU VE AKTİF FAVORİ BUTONU
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => _filterRestaurants(value),
              decoration: InputDecoration(
                hintText: "Restoran veya yemek arayın",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5D3EBD)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // ✅ FAVORİLER SAYFASINA GİDEN BUTON
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                // Tıklandığında Favoriler Sayfasına Gider
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                ).then((value) {
                  // Favorilerden geri dönüldüğünde ana sayfayı tazele
                  setState(() {});
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBar() {
    return Container(
      height: 50,
      color: const Color(0xFFF7D102),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF5D3EBD)),
            SizedBox(width: 8),
            Text(
              "Ev, Karabük Merkez...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D3EBD),
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Color(0xFF5D3EBD)),
          ],
        ),
      ),
    );
  }
}
