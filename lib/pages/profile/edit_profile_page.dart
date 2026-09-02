import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<AuthProvider>(context, listen: false).userData;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    _nameController = TextEditingController(text: userData?['name'] ?? '');
    _emailController = TextEditingController(text: userData?['email'] ?? '');
    _phoneController = TextEditingController(text: userData?['phone'] ?? user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateUserData({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil başarıyla güncellendi!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Güncelleme hatası: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profili Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Kişisel Bilgilerini Güncelle",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: "Ad Soyad",
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? "Lütfen isminizi girin" : null,
              ),
              const SizedBox(height: 16),

              // Phone Field (Read only)
              _buildTextField(
                controller: _phoneController,
                label: "Telefon Numarası",
                icon: Icons.phone_android_rounded,
                readOnly: true,
                hint: "Giriş yapılan numara değiştirilemez",
              ),
              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: "E-posta",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return "Lütfen e-posta girin";
                  if (!v.contains('@')) return "Geçerli bir e-posta girin";
                  return null;
                },
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary)
                )
              : const Text(
                  "GÜNCELLEMELERİ KAYDET",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: readOnly ? Colors.grey[600] : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
