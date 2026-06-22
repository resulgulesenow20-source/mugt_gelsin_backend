import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  
  String? _selectedRestaurantId;
  String? _selectedRestaurantName;
  final Map<String, TextEditingController> _replyControllers = {};
  bool _isSavingReply = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Approved dükkanları çekerek reklam formu için dropdown oluşturmakta kullanacağız
  Future<List<Map<String, dynamic>>> _fetchApprovedRestaurants() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Dukkanlar')
          .where('isApproved', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['restaurantName'] ?? data['name'] ?? 'İsimsiz Restoran',
        };
      }).toList();
    } catch (e) {
      debugPrint("Restoranları çekme hatası: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Yönetici Paneli",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: "Dükkan Onayları"),
            Tab(icon: Icon(Icons.campaign_outlined), text: "Reklam Yönetimi"),
            Tab(icon: Icon(Icons.rate_review_outlined), text: "Yorum Cevaplama"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRestaurantApprovalsTab(),
          _buildAdvertisementManagementTab(),
          _buildReviewRepliesTab(),
        ],
      ),
    );
  }

  // --- RESTORAN ONAYLARI TABI ---
  Widget _buildRestaurantApprovalsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Dukkanlar')
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Bekleyen başvuru bulunamadı.",
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String docId = docs[index].id;
            return _buildRestaurantCard(docId, data);
          },
        );
      },
    );
  }

  Widget _buildRestaurantCard(String docId, Map<String, dynamic> data) {
    final String restaurantName = data['restaurantName'] ?? 'İsimsiz Restoran';
    final String ownerName = data['ownerName'] ?? 'Belirtilmemiş';
    final String phone = data['phone'] ?? docId;
    final String address = data['address'] ?? 'Adres belirtilmemiş';
    final Timestamp? timestamp = data['registrationDate'] as Timestamp?;
    final String dateStr = timestamp != null 
        ? DateFormat('dd.MM.yyyy HH:mm').format(timestamp.toDate())
        : 'Tarih yok';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Başvuru: $dateStr",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Bekliyor",
                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.person_outline, "Sahibi:", ownerName),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.phone_android_outlined, "Telefon:", phone),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on_outlined, "Adres:", address),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveRestaurant(docId, restaurantName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _rejectRestaurant(docId, restaurantName),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Başvuruyu Sil",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- REKLAM/KAMPANYA YÖNETİMİ TABI ---
  Widget _buildAdvertisementManagementTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCampaignDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Reklam Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Kampanyalar').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "Henüz reklam veya kampanya bulunmamaktadır.",
                    style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Fab kapanmasın diye bottom padding
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String docId = docs[index].id;
              return _buildCampaignCard(docId, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildCampaignCard(String docId, Map<String, dynamic> data) {
    final String title = data['title'] ?? 'İsimsiz Reklam';
    final String description = data['description'] ?? '';
    final String? imageUrl = data['imageUrl'] ?? data['image_url'] ?? data['Resim'];
    final bool isActive = data['isActive'] ?? true;
    final String type = data['type'] ?? 'percentage';
    final double value = (data['value'] as num?)?.toDouble() ?? 0.0;
    final String? code = data['code'];
    final String shopId = data['shop_id'] ?? data['shopId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl) as ImageProvider
                        : AssetImage(imageUrl) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isActive,
                        activeColor: AppColors.primary,
                        onChanged: (newValue) => _toggleCampaignStatus(docId, newValue),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (code != null && code.isNotEmpty)
                            Text(
                              "Kupon Kodu: $code",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
                            ),
                          Text(
                            "İndirim Değeri: ${type == 'percentage' ? '%$value' : '$value TMT'}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (shopId.isEmpty)
                            const Text(
                              "İlişkili Dükkan: Sistem Genelinde (Tüm Dükkanlar)",
                              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                            )
                          else
                            FutureBuilder<DocumentSnapshot>(
                              future: _firestore.collection('Dukkanlar').doc(shopId).get(),
                              builder: (context, shopSnapshot) {
                                if (shopSnapshot.hasData && shopSnapshot.data!.exists) {
                                  final shopData = shopSnapshot.data!.data() as Map<String, dynamic>;
                                  return Text(
                                    "İlişkili Dükkan: ${shopData['restaurantName'] ?? shopData['name'] ?? 'Bilinmeyen'}",
                                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _deleteCampaign(docId, title),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KAMPANYA EKLEME DİYALOĞU ---
  void _showAddCampaignDialog() async {
    final List<Map<String, dynamic>> approvedShops = await _fetchApprovedRestaurants();
    
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController minAmountController = TextEditingController();

    String selectedType = 'percentage';
    String selectedShopId = ''; // Varsayılan olarak Sistem Genelinde

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Yeni Reklam/Kampanya Ekle", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Başlık *", hintText: "Örn: Gurme Burger Fırsatı"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Açıklama *", hintText: "Örn: Seçili burgerlerde %20 indirim"),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: "Görsel Linki (URL)",
                    hintText: "Örn: https://images.unsplash.com/...",
                  ),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: "Kupon Kodu (Varsa)", hintText: "Örn: BURGER20"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: "Kampanya Tipi"),
                  items: const [
                    DropdownMenuItem(value: 'percentage', child: Text("Yüzdelik İndirim (%)")),
                    DropdownMenuItem(value: 'fixed', child: Text("Sabit Tutar İndirimi (TMT)")),
                    DropdownMenuItem(value: 'coupon', child: Text("Kupon")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedType = val;
                      });
                    }
                  },
                ),
                TextField(
                  controller: valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "İndirim Miktarı/Değeri *", hintText: "Örn: 20"),
                ),
                TextField(
                  controller: minAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Minimum Sepet Tutarı (TMT)", hintText: "Örn: 50"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShopId,
                  decoration: const InputDecoration(labelText: "İlişkili Dükkan"),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text("Sistem Genelinde (Dükkan İlişkisi Yok)"),
                    ),
                    ...approvedShops.map((shop) {
                      return DropdownMenuItem<String>(
                        value: shop['id'],
                        child: Text(shop['name']),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setDialogState(() {
                      selectedShopId = val ?? '';
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    descController.text.trim().isEmpty ||
                    valueController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lütfen zorunlu (*) alanları doldurun."), backgroundColor: Colors.red),
                  );
                  return;
                }

                final double? val = double.tryParse(valueController.text);
                final double minAmt = double.tryParse(minAmountController.text) ?? 0.0;

                if (val == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("İndirim miktarı geçerli bir sayı olmalıdır."), backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  await _firestore.collection('Kampanyalar').add({
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'imageUrl': imageController.text.trim(),
                    'code': codeController.text.trim().isNotEmpty ? codeController.text.trim().toUpperCase() : null,
                    'type': selectedType,
                    'value': val,
                    'minAmount': minAmt,
                    'shop_id': selectedShopId ?? '',
                    'isActive': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reklam başarıyla eklendi! 🚀"), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text("Ekle"),
            ),
          ],
        ),
      ),
    );
  }

  // --- ACTIONS ---
  Future<void> _toggleCampaignStatus(String docId, bool status) async {
    try {
      await _firestore.collection('Kampanyalar').doc(docId).update({
        'isActive': status,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteCampaign(String docId, String title) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reklamı Sil"),
        content: Text("'$title' reklamını silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('Kampanyalar').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reklam silindi."), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _approveRestaurant(String docId, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Onay"),
        content: Text("$name restoranını onaylamak istiyor musunuz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text("Evet, Onayla"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('Dukkanlar').doc(docId).update({
          'isApproved': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$name onaylandı! ✨"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _rejectRestaurant(String docId, String name) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Başvuruyu Sil"),
        content: Text("$name restoran başvurusunu silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Vazgeç")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('Dukkanlar').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Başvuru silindi."), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- YORUM CEVAPLAMA TABI ---
  Widget _buildReviewRepliesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchApprovedRestaurants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Yorumlarını cevaplayabileceğiniz onaylı bir restoran bulunamadı."),
          );
        }

        final restaurants = snapshot.data!;

        return Column(
          children: [
            // Restoran Seçim Kartı
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text(
                      "Restoran Seçin:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRestaurantId,
                        hint: const Text("Seçiniz..."),
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: restaurants.map((res) {
                          return DropdownMenuItem<String>(
                            value: res['id'],
                            child: Text(res['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedRestaurantId = val;
                            _selectedRestaurantName = restaurants.firstWhere((r) => r['id'] == val)['name'];
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Seçili Restorana Ait Yorumlar
            Expanded(
              child: _selectedRestaurantId == null
                  ? const Center(
                      child: Text("Yorumları listelemek için yukarıdan bir restoran seçin."),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('Yorumlar')
                          .snapshots(),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Bu restorana ait yorum bulunamadı."));
                        }

                        // Restorana göre filtreleme
                        final docs = reviewSnapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final shopId = data['shopId']?.toString() ?? data['shop_id']?.toString() ?? data['restaurantId']?.toString() ?? '';
                          return shopId == _selectedRestaurantId;
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(child: Text("Bu restorana ait yorum bulunamadı."));
                        }

                        // Tarihe göre sırala
                        docs.sort((a, b) {
                          final aTime = a['createdAt'] ?? a['timestamp'];
                          final bTime = b['createdAt'] ?? b['timestamp'];
                          if (aTime is Timestamp && bTime is Timestamp) {
                            return bTime.compareTo(aTime);
                          }
                          return 0;
                        });

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final userName = data['userName'] ?? data['customerName'] ?? 'Anonim';
                            final comment = data['comment'] ?? '';
                            final rating = data['rating']?.toString() ?? '0.0';
                            final currentReply = data['reply']?.toString() ?? '';
                            final userId = data['userId']?.toString() ?? '';
                            
                            // Initialize controller for this review
                            if (!_replyControllers.containsKey(doc.id)) {
                              _replyControllers[doc.id] = TextEditingController(text: currentReply);
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Üst Bilgi Satırı
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                rating,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Yorum İçeriği
                                    Text(
                                      comment,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),

                                    // Cevap Bölümü
                                    Row(
                                      children: [
                                        const Icon(Icons.reply, size: 18, color: Colors.blueAccent),
                                        const SizedBox(width: 6),
                                        Text(
                                          currentReply.isNotEmpty ? "Cevabınız:" : "Cevap Yazın:",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _replyControllers[doc.id],
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        hintText: "Cevabınızı buraya yazın...",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                        fillColor: Colors.grey.shade50,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Colors.blueAccent),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: _isSavingReply 
                                            ? null 
                                            : () => _saveReply(
                                                  doc.id, 
                                                  comment, 
                                                  userId, 
                                                  _replyControllers[doc.id]!.text.trim(),
                                                ),
                                        icon: const Icon(Icons.send_rounded, size: 16),
                                        label: Text(currentReply.isNotEmpty ? "Cevabı Güncelle" : "Cevapla"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReply(String reviewDocId, String comment, String userId, String replyText) async {
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen boş cevap göndermeyin."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSavingReply = true;
    });

    try {
      // 1. Yorumlar Koleksiyonunu Güncelle
      await _firestore.collection('Yorumlar').doc(reviewDocId).update({
        'reply': replyText,
      });

      // 2. Reviews Koleksiyonundaki Eşleşen Yorumu Güncelle
      final reviewsQuery = await _firestore
          .collection('Reviews')
          .where('userId', isEqualTo: userId)
          .where('comment', isEqualTo: comment)
          .get();

      for (var doc in reviewsQuery.docs) {
        await doc.reference.update({
          'reply': replyText,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cevabınız başarıyla kaydedildi."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cevap kaydedilirken hata oluştu: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingReply = false;
        });
      }
    }
  }
}
