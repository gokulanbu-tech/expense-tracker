import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/screens/sync_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSettingsTile(
            context,
            "Synchronization",
            "Manage SMS and Email sync strategies",
            Icons.sync_rounded,
            const SyncSettingsScreen(),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            "Notifications",
            "Configure budget alerts and reminders",
            Icons.notifications_outlined,
            const Center(child: Text("Notifications - Coming Soon")),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            "Security",
            "Privacy and account security",
            Icons.security_rounded,
            const Center(child: Text("Security - Coming Soon")),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, String subtitle, IconData icon, Widget target) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => target),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
