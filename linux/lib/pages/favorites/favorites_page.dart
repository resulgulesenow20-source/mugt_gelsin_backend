import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();

    // ✅ BURASI ÖNEMLİ: Provider içindeki listenin adı sendeki dosyada neyse o olmalı.
    // Eğer 'favorites' hata veriyorsa, sendeki Provider dosyasında 'get' ile başlayan
    // listenin ismine bak. Muhtemelen 'favorites' olmalı ama hata verdiğine göre
    // Provider dosyanı kontrol et.
    final favoriteList = favProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorilerim"),
        backgroundColor: const Color(0xFF5D3EBD),
        foregroundColor: Colors.white,
      ),
      body: favoriteList.isEmpty
          ? const Center(child: Text("Favori restoran bulunamadı."))
          : ListView.builder(
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                final res = favoriteList[index];
                return ListTile(
                  leading: Image.network(res.imageUrl, width: 50),
                  title: Text(res.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => favProvider.toggleFavorite(res),
                  ),
                );
              },
            ),
    );
  }
}
