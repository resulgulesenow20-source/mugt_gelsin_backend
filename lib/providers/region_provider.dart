import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/region_model.dart';

class RegionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Region> _regions = [];
  bool _isLoading = false;
  String? _selectedGuestRegion;

  List<Region> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get selectedGuestRegion => _selectedGuestRegion;

  RegionProvider() {
    loadGuestRegion();
  }

  Future<void> loadGuestRegion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedGuestRegion = prefs.getString('selectedGuestRegion');
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading guest region: $e");
    }
  }

  Future<void> setGuestRegion(String region) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedGuestRegion', region);
      _selectedGuestRegion = region;
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving guest region: $e");
    }
  }

  final List<Region> _dummyRegions = [
    Region(id: 'ashgabat', name: 'Aşgabat', districts: [
      'Bagtyýarlyk',
      'Berkararlyk',
      'Büzmeýin',
      'Köpetdag',
    ]),
    Region(id: 'ahal', name: 'Ahal', districts: [
      'Ak bugdaý',
      'Bäherden',
      'Gökdepe',
      'Kaka',
      'Sarahs',
      'Tejen',
    ]),
    Region(id: 'balkan', name: 'Balkan', districts: [
      'Balkanabat',
      'Serdar',
      'Bereket',
      'Etrek',
      'Magtymguly',
    ]),
    Region(id: 'mary', name: 'Mary', districts: [
      'Mary',
      'Baýramaly',
      'Murgap',
      'Sakarçäge',
      'Türkmengala',
      'Ýolöten',
    ]),
    Region(id: 'lebap', name: 'Lebap', districts: [
      'Türkmenabat',
      'Çärjew',
      'Dänew',
      'Kerki',
      'Saýat',
      'Halaç',
    ]),
    Region(id: 'dasoguz', name: 'Daşoguz', districts: [
      'Daşoguz',
      'Boldumsaz',
      'Gubadag',
      'Akdepe',
      'Köneürgenç',
      'Ruhubelent',
    ]),
    Region(id: 'turkmenbasi', name: 'Türkmenbaşı', districts: [
      'Awaza',
      'Kenar',
      'Hazar',
      'Şagadam',
      'Garagum',
      'Port (Liman) çevresi',
      'Aeroport (Havalimanı)',
    ]),
  ];

  Future<void> fetchRegions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Force use of dummy regions instead of Firestore as requested by the user
      _regions = _dummyRegions;
      
      // If we ever want to use Firestore again, we can uncomment the below:
      /*
      final snapshot = await _firestore.collection('Bolgeler').get();
      if (snapshot.docs.isEmpty) {
        _regions = _dummyRegions;
      } else {
        _regions = snapshot.docs.map((doc) => Region.fromMap(doc.id, doc.data())).toList();
      }
      */
    } catch (e) {
      debugPrint('Error fetching regions: $e');
      _regions = _dummyRegions; // Fallback on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper function to seed dummy data to Firestore (can be called if needed)
  Future<void> _seedDummyRegions() async {
    for (var region in _dummyRegions) {
      await _firestore.collection('Bolgeler').doc(region.id).set(region.toMap());
    }
  }
}
