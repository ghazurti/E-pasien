import 'package:flutter/material.dart';
import '../config/theme.dart';

class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  LinearGradient _selectedGradient = AppTheme.professionalGradient;
  String _gradientName = "Professional (Deep Blue)";

  void _updateGradient(LinearGradient gradient, String name) {
    setState(() {
      _selectedGradient = gradient;
      _gradientName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uji Coba Warna Gradien')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Card
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 200,
              decoration: BoxDecoration(
                gradient: _selectedGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      _gradientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      "Klik tombol di bawah untuk ganti warna",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Pilih Tema Warna:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Selection Buttons
            _buildThemeButton(
              "Professional Blue",
              AppTheme.professionalGradient,
              "Professional (Deep Blue)",
            ),
            _buildThemeButton(
              "Calming Teal",
              AppTheme.calmingGradient,
              "Calming (Teal Green)",
            ),
            _buildThemeButton(
              "Modern Purple",
              AppTheme.modernGradient,
              "Modern (Purple Magenta)",
            ),
            _buildThemeButton(
              "Clean Grey",
              AppTheme.cleanGradient,
              "Clean (Grey White)",
              isDark: false,
            ),
            _buildThemeButton(
              "Premium Navy",
              AppTheme.premiumGradient,
              "Premium (Royal Navy)",
            ),
            _buildThemeButton(
              "Energetic Red",
              AppTheme.energeticGradient,
              "Energetic (Orange Red)",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    String label,
    LinearGradient gradient,
    String fullName, {
    bool isDark = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _updateGradient(gradient, fullName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
