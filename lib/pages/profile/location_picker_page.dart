import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/geocoding_helper.dart'; // âœ… Yeni izole edilmiÅŸ yardÄ±mcÄ±

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerPage({super.key, this.initialLocation});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(37.96, 58.32); // Default to Ashgabat
  String _currentAddress = "Konum yükleniyor..";
  String _currentCity = "";
  String _currentDistrict = "";
  String _currentStreet = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentPosition = widget.initialLocation!;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showLocationPrompt();
    });
  }

  void _showLocationPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Mevcut Konum", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Harita üzerinde şu an bulunduğunuz konuma gitmek ister misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hayır", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _determinePosition();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Konumumu Bul", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    _setLoading(true);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLoading(false);
      _showErrorSnackBar('Konum servisleri kapalı. Lütfen konumunuzu açın.', 'AYARLAR', () {
        Geolocator.openLocationSettings();
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLoading(false);
        _showErrorSnackBar('Konum izni reddedildi.', 'İZİN VER', () {
          Geolocator.requestPermission();
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setLoading(false);
      _showErrorSnackBar('Konum izni kalıcı olarak reddedildi.', 'AYARLAR', () {
        Geolocator.openAppSettings();
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (!mounted) return;
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 15);
      });
      
      await _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      debugPrint("Konum alma hatası: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _showErrorSnackBar(String message, String? actionLabel, VoidCallback? onAction) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        action: actionLabel != null ? SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: onAction!) : null,
      ),
    );
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    final result = await GeocodingHelper.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    if (result != null && mounted) {
      setState(() {
        _currentAddress = result['fullAddress'] ?? '';
        _currentCity = result['city'] ?? '';
        _currentDistrict = result['district'] ?? '';
        _currentStreet = result['street'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Konum Seç",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SizedBox.expand( 
        child: Stack(
          children: [
            Container(color: Colors.grey[200]),
            
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 15,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _currentPosition = position.center!;
                    });
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    _getAddressFromLatLng(_currentPosition);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.company.mugut_gelsin_app_v1',
                  tileDisplay: const TileDisplay.fadeIn(),
                ),
              ],
            ),
            
            // Search Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty || textEditingValue.text.length < 3) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  final results = await GeocodingHelper.searchAddress(textEditingValue.text);
                  return results;
                },
                displayStringForOption: (option) => option['displayName'] ?? '',
                onSelected: (option) {
                  FocusScope.of(context).unfocus();
                  final lat = option['lat'] as double;
                  final lon = option['lon'] as double;
                  setState(() {
                    _currentPosition = LatLng(lat, lon);
                    _mapController.move(_currentPosition, 16);
                  });
                  _getAddressFromLatLng(_currentPosition);
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        hintText: "Konum arayın...",
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: AppColors.primary),
                              title: Text(option['displayName'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Static Center Pin
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          _isLoading ? "Yükleniyor..." : "Konumunuz Burası mı?",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.location_on_rounded, size: 50, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Info & Confirm Button
            Positioned(
              left: 16,
              right: 16,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentCity.isNotEmpty ? "$_currentCity, $_currentDistrict" : "Seçilen Adres",
                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentAddress,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pop(context, {
                          'address': _currentAddress,
                          'city': _currentCity,
                          'district': _currentDistrict,
                          'street': _currentStreet,
                          'lat': _currentPosition.latitude,
                          'lng': _currentPosition.longitude,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "KONUMU ONAYLA",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom / 2),
                  ],
                ),
              ),
            ),
            
            // Current Location Button
            Positioned(
              right: 16,
              bottom: 230,
              child: FloatingActionButton(
                onPressed: _determinePosition,
                backgroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.my_location_rounded, color: AppColors.primary),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
