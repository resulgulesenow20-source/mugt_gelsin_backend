import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugt_gelsin/core/constants/app_colors.dart';
import 'package:mugt_gelsin/pages/main_screen.dart';
import 'package:mugt_gelsin/providers/language_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String _countryCode = "+90"; 

  void _register() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);

    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(langProvider.translate('fill_all_fields'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String fullPhone = "$_countryCode${_phoneController.text.trim().replaceAll(' ', '')}";

      if (!_codeSent) {
        // Step 1: Send Code
        await authProvider.verifyPhoneNumber(
          phoneNumber: fullPhone,
          onCodeSent: (verificationId) {
            setState(() {
              _codeSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Doğrulama kodu gönderildi.")),
            );
          },
          onError: (error) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          },
        );
      } else {
        // Step 2: Verify OTP
        if (_codeController.text.isEmpty) {
          throw "Lütfen doğrulama kodunu girin.";
        }
        await authProvider.signInWithOTP(
          _codeController.text.trim(),
          name: _nameController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(langProvider.translate('register_success'))),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted && !_codeSent) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(langProvider.translate('register_title')),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              langProvider.translate('create_account'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              langProvider.translate('register_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            // Kayıt Alanları
            if (!_codeSent) ...[
              _buildTextField(
                controller: _nameController,
                hintText: langProvider.translate('full_name'),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                hintText: langProvider.translate('phone_label'),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                prefix: GestureDetector(
                  onTap: () {
                    _showCountryPicker(context);
                  },
                  child: Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Text(
                      _countryCode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.sms_outlined, color: AppColors.primary, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Kodu Doğrula",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$_countryCode${_phoneController.text} numarasına bir SMS kodu gönderdik.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 10,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "******",
                        hintStyle: TextStyle(color: Colors.grey.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Kayıt Ol Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _codeSent ? "DOĞRULA VE KAYIT OL" : langProvider.translate('register_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ),
            ),
            if (_codeSent)
              TextButton(
                onPressed: () => setState(() => _codeSent = false),
                child: const Text("Bilgileri Düzenle", style: TextStyle(color: AppColors.textSecondary)),
              ),
            const SizedBox(height: 16),

            // Giriş Yap Linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  langProvider.translate('already_have_account'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    langProvider.translate('login_button'),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: prefix ?? Icon(icon, color: AppColors.textPrimary),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCountryOption(context, "Türkiye", "+90"),
              _buildCountryOption(context, "Türkmenistan", "+993"),
              _buildCountryOption(context, "Rusya", "+7"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountryOption(BuildContext context, String name, String code) {
    return ListTile(
      title: Text(name),
      trailing: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        setState(() {
          _countryCode = code;
        });
        Navigator.pop(context);
      },
    );
  }
}
