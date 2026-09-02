import 'package:flutter/material.dart';
import 'package:mugut_gelsin/pages/auth/register_page.dart';
import 'package:provider/provider.dart';
import 'package:mugut_gelsin/providers/auth_provider.dart' as app_auth;
import 'package:mugut_gelsin/providers/language_provider.dart';

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
  String _countryCode = "+993"; 

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
        await authProvider.verifyPhoneNumber(
          phoneNumber: fullPhone,
          onCodeSent: (verificationId) {
            setState(() {
              _codeSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(langProvider.get('code_sent_msg'))),
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
        if (_codeController.text.isEmpty) {
          throw langProvider.get('enter_code_error');
        }
        await authProvider.signInWithOTP(_codeController.text.trim());
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        if (_codeSent) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1F113D),
      body: Stack(
        children: [
          // Background Image (Top Half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Image.asset(
              'assets/images/splash_logo.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                 return const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50));
              }
            ),
          ),
          
          // Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
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
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 8),
                              child: Icon(Icons.phone_rounded, color: const Color(0xFF6B528B), size: 20),
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
                        onPressed: _isLoading ? null : _login,
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
                                _codeSent ? langProvider.get('verify_code') : "Kod iber",
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
            ),
          ),
        ],
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
