import 'package:flutter/material.dart';
import 'package:mobile_dashboard/screens/login_screen.dart';
import 'package:mobile_dashboard/utils/constants.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Constants.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Constants.primaryColor.withOpacity(0.2),
                    child: const Icon(LucideIcons.user, size: 40, color: Constants.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Owner Administrator',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'admin123',
                    style: TextStyle(color: Constants.textMutedColor),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.edit2, size: 16),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Options
            _buildSettingItem(
              icon: LucideIcons.bell,
              title: 'Notifications',
              subtitle: 'Enabled (Tick)',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: LucideIcons.moon,
              title: 'Theme',
              subtitle: 'Dark Mode (Always On)',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: LucideIcons.languages,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: LucideIcons.shield,
              title: 'Security',
              subtitle: 'Password managed by Admin',
              onTap: () {},
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(LucideIcons.logOut),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 0.5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'App Version 2.0.0',
              style: TextStyle(color: Constants.textMutedColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Constants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Constants.accentColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Constants.textMutedColor, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Constants.textMutedColor),
        onTap: onTap,
      ),
    );
  }
}
