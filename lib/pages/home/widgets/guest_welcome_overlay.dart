import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/pages/auth/register_page.dart';

class GuestWelcomeOverlay extends StatefulWidget {
  const GuestWelcomeOverlay({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const GuestWelcomeOverlay(),
        );
      },
    );
  }

  @override
  State<GuestWelcomeOverlay> createState() => _GuestWelcomeOverlayState();
}

class _GuestWelcomeOverlayState extends State<GuestWelcomeOverlay> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String _selectedRegion = "Aşkabat"; // Default region
  String _countryCode = "+993";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().fetchRegions();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _verifyPhone() async {
    final authProvider = context.read<AuthProvider>();
    final langProvider = context.read<LanguageProvider>();

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(langProvider.translate('fill_all_fields'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    String fullPhone = "$_countryCode${_phoneController.text.trim().replaceAll(' ', '')}";

    await authProvider.verifyPhoneNumber(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _codeSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(langProvider.get('code_sent_msg'))),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  void _submitCode() async {
    final authProvider = context.read<AuthProvider>();
    final langProvider = context.read<LanguageProvider>();
    final regionProvider = context.read<RegionProvider>();

    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(langProvider.get('enter_code_error'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authProvider.signInWithOTP(_codeController.text.trim());
      // Save the region after successful login
      await regionProvider.setGuestRegion(_selectedRegion);
      
      if (mounted) {
        Navigator.pop(context); // Close the bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final regionProvider = context.watch<RegionProvider>();

    if (regionProvider.regions.isNotEmpty && _selectedRegion == "Aşkabat") {
      final ashgabat = regionProvider.regions.where((r) => r.name.toLowerCase().contains("asgabat") || r.name.toLowerCase().contains("aşkabat")).firstOrNull;
      if (ashgabat != null) {
        _selectedRegion = ashgabat.name;
      } else {
        _selectedRegion = regionProvider.regions.first.name;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Close Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            
            // Language Toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLangButton(context, 'TM', 'TM', '+993'),
                  _buildLangButton(context, 'RU', 'RU', '+7'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            Text(
              _codeSent ? langProvider.get('verify_code') : "Hoş geldiňiz",
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E1A47),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              _codeSent 
                ? langProvider.get('sms_sent_to').replaceAll('{phone}', "$_countryCode${_phoneController.text}") 
                : "Sargytlaryňyz gapyňyza çalt we ýyly gelsin.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            
            // Input Field
            if (!_codeSent) 
              Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _countryCode,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E1A47),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Icon(Icons.phone_rounded, color: Color(0xFF6B528B), size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E1A47),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: langProvider.translate('phone_hint') != 'phone_hint' ? langProvider.translate('phone_hint') : "Telefon belgiňiz",
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[400],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else 
              Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E1A47),
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: "******",
                    hintStyle: TextStyle(
                      color: Colors.grey[300],
                      letterSpacing: 8,
                    ),
                  ),
                ),
              ),
              
            const SizedBox(height: 24),
            
            // Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_codeSent ? _submitCode : _verifyPhone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD500), // Yellow
                  foregroundColor: const Color(0xFF2E1A47), // Dark Purple text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Color(0xFF2E1A47), strokeWidth: 3),
                      )
                    : Text(
                        _codeSent ? langProvider.get('verify') : "Kod iber",
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _codeSent = false),
                child: Text(
                  "Telefon belgisini üýtget", 
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            
            if (!_codeSent) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey[600]),
                      children: const [
                         TextSpan(text: "Dowam etmek bilen "),
                         TextSpan(text: "şertleri", style: TextStyle(fontWeight: FontWeight.bold)),
                         TextSpan(text: " kabul edýärsiňiz."),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF6B7280)),
                    children: [
                      TextSpan(text: "Hasabyňyz ýokmy? "),
                      TextSpan(text: "Hasap açyň", style: TextStyle(color: Color(0xFF2E1A47), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String code, String label, String phonePrefix) {
    final langProvider = context.watch<LanguageProvider>();
    bool isSelected = langProvider.selectedLang == code;
    return InkWell(
      onTap: () {
        langProvider.setLanguage(code);
        setState(() {
          _countryCode = phonePrefix;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD500) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSelected ? const Color(0xFF2E1A47) : Colors.grey[500],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
