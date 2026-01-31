import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/screens/edit_profile_screen.dart';
import 'package:expense_tracker_mobile/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The user is now a User object, not a Map
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                    child: Text(
                      (user?.firstName.isNotEmpty == true) ? user!.firstName[0].toUpperCase() : "U",
                      style: const TextStyle(color: Color(0xFF6366F1), fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoCard([
              _buildInfoRow(Icons.account_balance_wallet_outlined, "Monthly Budget", "₹ ${user?.monthlyBudget ?? 0}"),
              const Divider(color: Colors.white12, height: 32),
              _buildInfoRow(Icons.phone_android_rounded, "Mobile Number", user?.mobileNumber ?? ""),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Edit Profile", style: TextStyle(color: Color(0xFF6366F1), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF0F172A),
                      title: const Text("Logout", style: TextStyle(color: Colors.white)),
                      content: const Text("Are you sure you want to logout?", style: TextStyle(color: Colors.grey)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<UserProvider>().logout();
                  }
                },
                child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigoAccent, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
