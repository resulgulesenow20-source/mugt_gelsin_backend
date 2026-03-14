import 'package:flutter/material.dart';
import 'package:mugt_gelsin/pages/auth/register_page.dart';
import 'package:mugt_gelsin/pages/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:mugt_gelsin/providers/auth_provider.dart' as app_auth;
// Giriş başarılı olunca gidecek yer
import 'package:mugt_gelsin/providers/language_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String _countryCode = "+90"; 

  void _login() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    
    if (_phoneController.text.isEmpty) {
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
        await authProvider.signInWithOTP(_codeController.text.trim());
        if (mounted) {
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
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF6900), Color(0xFFFF8E53)],
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo Alanı (Sürekli Nefes Alan Animasyon)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.9, end: 1.0),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOutSine,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/logo_m.png',
                                height: _codeSent ? 100 : 180, // Kod gönderilince logoyu küçült
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (!_codeSent) ...[
                        const Text(
                          "Mugt Gelsin",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          langProvider.translate('tagline'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      SizedBox(height: _codeSent ? 10 : 30),

                      // Dil Seçimi Bölümü
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLangButton(context, 'TR', 'Türkçe', '+90'),
                          const SizedBox(width: 12),
                          _buildLangButton(context, 'TM', 'Türkmen', '+993'),
                          const SizedBox(width: 12),
                          _buildLangButton(context, 'RU', 'Русский', '+7'),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Giriş Alanları
                      if (!_codeSent) ...[
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: langProvider.translate('phone_label'),
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: langProvider.translate('phone_hint'),
                            hintStyle: const TextStyle(color: Colors.white54),
                            prefixIcon: Container(
                              width: 60,
                              alignment: Alignment.center,
                              child: Text(
                                _countryCode,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                "SMS Doğrulama",
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$_countryCode${_phoneController.text} numarasına 6 haneli bir kod gönderdik.",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 6,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 12),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "******",
                                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Giriş Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFFF6900),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFFFF6900))
                              : Text(
                                  _codeSent ? "DOĞRULA" : langProvider.translate('login_button'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                      if (_codeSent)
                        TextButton(
                          onPressed: () => setState(() => _codeSent = false),
                          child: const Text("Numarayı Değiştir", style: TextStyle(color: Colors.white70)),
                        ),
                      const SizedBox(height: 24),

                      // Kayıt Ol Linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            langProvider.translate('no_account'),
                            style: const TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              langProvider.translate('signup'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String code, String label, String countryCode) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isSelected = langProvider.selectedLang == code;
    return InkWell(
      onTap: () {
        langProvider.setLanguage(code);
        setState(() {
          _countryCode = countryCode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
