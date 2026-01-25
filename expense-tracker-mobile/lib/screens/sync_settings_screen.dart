import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final userEmail = user?['email'] ?? "your-email@example.com";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Synchronization", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Active Sync Strategy"),
            const SizedBox(height: 16),
            _buildStrategyCard(
              context,
              "Email Forwarding (Recommended for iOS)",
              "Forward your bank alert emails to our cloud sync engine. No app permissions required.",
              Icons.alternate_email_rounded,
              Colors.blueAccent,
              _showEmailTutorial(context, userEmail),
            ),
            const SizedBox(height: 16),
            _buildStrategyCard(
              context,
              "Android SMS Sync",
              "Automatically captures bank SMS in the background. (Only works on Android devices).",
              Icons.android_rounded,
              Colors.greenAccent,
              null,
            ),
            const SizedBox(height: 32),
            _buildHeader("iOS Automation"),
            const SizedBox(height: 16),
            _buildStrategyCard(
              context,
              "iOS Shortcuts",
              "Create a shortcut to trigger a sync every time a bank SMS is received on your iPhone.",
              Icons.bolt_rounded,
              Colors.orangeAccent,
              _showShortcutsTutorial(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }

  Widget _buildStrategyCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (onTap != null) const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _showEmailTutorial(BuildContext context, String email) {
    return () {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E293B),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Email Forwarding Setup", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _step(1, "Open your email provider (Gmail/Outlook)"),
              _step(2, "Create a rule: Forward emails from 'Your Bank' to 'sync@expensetracker.com'"),
              _step(3, "Ensure the 'From' address is $email"),
              const SizedBox(height: 32),
              const Center(
                child: Text("Our backend will automatically link the email to your account.", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueAccent, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      );
    };
  }

  VoidCallback _showShortcutsTutorial(BuildContext context) {
    return () {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E293B),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("iOS Shortcut Sync", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _step(1, "Open iOS 'Shortcuts' App -> Automation"),
              _step(2, "Create 'Message' Automation triggered by Bank SMS"),
              _step(3, "Action: 'Get Contents of URL' (POST) to our API"),
              const SizedBox(height: 32),
              const Text("Full technical payload details can be found in the project documentation.", 
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    };
  }

  Widget _step(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, backgroundColor: Colors.blueAccent, child: Text(num.toString(), style: const TextStyle(fontSize: 10, color: Colors.white))),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }
}
