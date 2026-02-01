import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker_mobile/screens/all_expenses_screen.dart';
import 'package:expense_tracker_mobile/models/expense_model.dart';
import 'package:expense_tracker_mobile/screens/chat_screen.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  List<dynamic> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final user = context.read<UserProvider>().user;
      
      if (user != null) {
        final data = await api.getSuggestions(user.id);
        setState(() {
          _suggestions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating insights: $e")),
        );
      }
    }
  }

  Future<void> _handleAction(Map<String, dynamic> item) async {
    final type = item['type'].toString().toLowerCase();
    final category = item['category'].toString();
    final title = item['title'].toString();
    // Safely get merchant, allowing for null
    final String? merchant = item['merchant']?.toString();

    if (type == 'subscription') {
      // Search Google for cancellation
      final query = Uri.encodeComponent("How to cancel $title subscription");
      final url = Uri.parse("https://www.google.com/search?q=$query");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch browser")),
           );
        }
      }
    } else {
      // Navigate to expenses filtered by this merchant or category
      setState(() => _isLoading = true);
      try {
         final api = context.read<ApiService>();
         final user = context.read<UserProvider>().user;
         if (user != null) {
           final allExpenses = await api.getExpenses(user.id);
           
           List<Expense> filtered;
           if (merchant != null && merchant.isNotEmpty) {
             // Filter by merchant name (case-insensitive partial match)
             filtered = allExpenses.where((e) => 
               e.merchant.toLowerCase().contains(merchant.toLowerCase())
             ).toList();
           } else {
             // Fallback to category
             filtered = allExpenses.where((e) => 
               e.category.toLowerCase() == category.toLowerCase()
             ).toList();
           }
           
           if (mounted) {
              setState(() => _isLoading = false);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AllExpensesScreen(expenses: filtered)),
              );
           }
         }
      } catch (e) {
         if (mounted) {
           setState(() => _isLoading = false);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Error fetching details: $e")),
           );
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("AI Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text("Ask AI"),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Smart ways to reduce your spending",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return _buildSuggestionCard(item);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
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
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                item['category'].toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            item['title'],
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            item['description'],
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Potential Savings", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    "₹ ${item['potentialSavings']}/mo",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _handleAction(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Text("Take Action"),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
