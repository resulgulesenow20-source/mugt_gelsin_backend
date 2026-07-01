import 'package:flutter/material.dart';
import 'package:mugut_gelsin/core/constants/app_colors.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart';
import 'package:mugut_gelsin/providers/language_provider.dart';
import 'package:mugut_gelsin/providers/region_provider.dart';
import 'package:provider/provider.dart';

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

    String fullPhone = "+993${_phoneController.text.trim().replaceAll(' ', '')}";

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
      // Ensure selected region matches the actual name if available
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          
          // Language Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLangButton(context, 'TM', 'Türkmen', '+993'),
              const SizedBox(width: 12),
              _buildLangButton(context, 'TR', 'Türkçe', '+90'),
              const SizedBox(width: 12),
              _buildLangButton(context, 'RU', 'Русский', '+7'),
            ],
          ),
          const SizedBox(height: 32),

          Text(
            langProvider.translate('phone_login') ?? "Haýyş telefon nomeri bilen giriş ediň",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (!_codeSent) ...[
            // Region Selection Dropdown
            if (regionProvider.regions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRegion,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                    items: regionProvider.regions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region.name,
                        child: Text(region.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRegion = val);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Phone Number Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Text(
                    "+993",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: langProvider.get('phone_hint'),
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        langProvider.get('send_code'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ] else ...[
            // SMS Code Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "000000",
                  hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        langProvider.get('verify'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String code, String label, String phonePrefix) {
    final langProvider = context.watch<LanguageProvider>();
    bool isSelected = langProvider.selectedLang == code;

    return InkWell(
      onTap: () async {
        await langProvider.setLanguage(code);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Text(
          code,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
