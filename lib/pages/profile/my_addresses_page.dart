import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import 'add_address_page.dart';
import '../../providers/language_provider.dart';

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({super.key});

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    await Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EDFA), // Soft purple background from mockup
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD500)))
          : CustomScrollView(
              slivers: [
                // Top Image and Banner
                SliverAppBar(
                  expandedHeight: 380,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF2E1A47),
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF2E1A47), size: 20),
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fastfood, color: Color(0xFFFFD500), size: 24),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("MUGT", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, height: 1.0)),
                          const Text("GELSIN", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, height: 1.0)),
                        ],
                      ),
                      const SizedBox(width: 48), // Balance for leading icon
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // The generated 3D image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/delivery_map_banner.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Dark overlay gradient to make text readable
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF2E1A47).withOpacity(0.8),
                                  const Color(0xFF2E1A47).withOpacity(0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.4, 0.7],
                              ),
                            ),
                          ),
                        ),
                        // The Text on the banner
                        Positioned(
                          top: 110,
                          left: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nire eltmeli?",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Şu gün haýsy ýere?",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Wavy shape overlay at the bottom of the map
                        Positioned(
                          bottom: -2,
                          left: 0,
                          right: 0,
                          height: 35,
                          child: ClipPath(
                            clipper: WavyTopClipper(),
                            child: Container(
                              color: const Color(0xFFF3EDFA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content area
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Column(
                      children: [
                        // Yellow "Fast delivery" badge bridging the image and the list
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD500),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded, size: 20, color: Color(0xFF2E1A47)),
                                const SizedBox(width: 8),
                                const Text(
                                  "Çalt eltip bermek üçin saýla",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF2E1A47),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Addresses list
                        if (addressProvider.addresses.isEmpty)
                          _buildEmptyState(langProvider)
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: addressProvider.addresses.map((address) {
                                return _buildAddressCard(address, addressProvider, langProvider);
                              }).toList(),
                            ),
                          ),
                          
                        const SizedBox(height: 24),
                        
                        // Add new address button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddAddressPage()),
                            ),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF0D5), // Soft yellowish background
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFFFFD500).withOpacity(0.5), width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF2E1A47), width: 1.5, style: BorderStyle.none), 
                                    ),
                                    child: const Icon(Icons.add, color: Color(0xFF2E1A47), size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "+ Täze adres goş",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF2E1A47),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.location_on, size: 64, color: Color(0xFF2E1A47)),
            const SizedBox(height: 16),
            Text(
              lang.get('no_address'),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E1A47)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address, AddressProvider provider, LanguageProvider lang) {
    final isSelected = address.isDefault;

    // Determine icon and color based on type
    IconData iconData = Icons.place;
    if (address.type == 'home') iconData = Icons.home_rounded;
    if (address.type == 'work') iconData = Icons.business_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD500) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E1A47).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.setDefaultAddress(address.id),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 3D-like Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    color: const Color(0xFF4A2F7C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Address Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF2E1A47),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD500),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "ESASY",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color(0xFF2E1A47), 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${address.district}, ${address.city}",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF6B528B), // Slightly lighter purple
                          fontSize: 14, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${address.street} No:${address.buildingNo}, K:${address.floor} D:${address.doorNo}",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.grey.shade600, 
                          fontSize: 13, 
                          fontWeight: FontWeight.w500
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Selection Radio / Check
                const SizedBox(width: 12),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFFFD500) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFD500) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected 
                      ? const Icon(Icons.check, color: Color(0xFF2E1A47), size: 18)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WavyTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 15);
    
    path.quadraticBezierTo(size.width * 0.25, -5, size.width * 0.5, 10);
    path.quadraticBezierTo(size.width * 0.75, 25, size.width, 15);
    
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
