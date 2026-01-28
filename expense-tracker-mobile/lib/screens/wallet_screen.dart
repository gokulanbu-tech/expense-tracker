// Forces Re-build
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/screens/add_bill_screen.dart';
import 'package:expense_tracker_mobile/screens/bill_details_screen.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<dynamic> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      final api = context.read<ApiService>();
      if (user != null) {
        final data = await api.getBills(user['id']);
        // Sort by due date ascending (soonest first)
        data.sort((a, b) => DateTime.parse(a['dueDate']).compareTo(DateTime.parse(b['dueDate'])));
        if (mounted) {
          setState(() {
            _bills = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading bills: $e")),
        );
      }
    }
  }

  Future<void> _payBill(String id, String merchant) async {
    try {
      final api = context.read<ApiService>();
      await api.markBillAsPaid(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Paid $merchant successfully!"), backgroundColor: Colors.green),
        );
        _fetchBills(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pay bill: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBill(String id) async {
    try {
      final api = context.read<ApiService>();
      await api.deleteBillBackend(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bill deleted")),
        );
        _fetchBills();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting bill: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Recurring Bills", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBillScreen()),
              );
              if (result == true) _fetchBills();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _bills.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bills.length,
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    return _buildBillCard(bill);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No recurring bills yet.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
               final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBillScreen()),
              );
              if (result == true) _fetchBills();
            },
            child: const Text("Add your first bill"),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(dynamic bill) {
    final date = DateTime.parse(bill['dueDate']);
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    Color dueColor = Colors.white70;
    if (difference < 0) {
      dueColor = Colors.redAccent;
    } else if (difference <= 3) {
      dueColor = Colors.orangeAccent;
    } else {
      dueColor = const Color(0xFF10B981); // Green safe
    }

    return Dismissible(
      key: Key(bill['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text("Delete Bill?", style: TextStyle(color: Colors.white)),
            content: const Text("This will stop future tracking for this bill.", style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
              TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.of(ctx).pop(true)),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteBill(bill['id']),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BillDetailsScreen(bill: bill)),
          );
          // If result is true (deleted or updated), refresh list
          if (result == true) _fetchBills();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: _getCategoryColor(bill['category']).withOpacity(0.2),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Icon(_getIconForCategory(bill['category']), color: _getCategoryColor(bill['category'])),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill['merchant'] ?? "Unknown",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: dueColor),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(date),
                          style: TextStyle(color: dueColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        if (bill['frequency'] != null) ...[
                           const SizedBox(width: 8),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: Colors.white10,
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               bill['frequency'],
                               style: const TextStyle(color: Colors.white54, fontSize: 10),
                             ),
                           )
                        ]
                      ],
                    ),
                    if (bill['note'] != null && (bill['note'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          bill['note'],
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹ ${bill['amount']}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final due = DateTime.parse(bill['dueDate']);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final dueDay = DateTime(due.year, due.month, due.day);
                      
                      if (today.isBefore(dueDay)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text("Cannot pay early. Due on ${DateFormat('MMM d, yyyy').format(due)}"),
                             backgroundColor: Colors.orangeAccent,
                           ),
                        );
                        return;
                      }
                      _payBill(bill['id'], bill['merchant']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Pay", style: TextStyle(fontSize: 12)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Food': return const Color(0xFF6366F1);
      case 'Transport': return const Color(0xFFA855F7);
      case 'Shopping': return const Color(0xFFEC4899);
      case 'Entertainment': return const Color(0xFFF59E0B);
      case 'Utilities': return const Color(0xFF10B981);
      case 'Health': return const Color(0xFFEF4444);
      case 'Travel': return const Color(0xFF06B6D4);
      default: return Colors.blueGrey;
    }
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'Food': return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_bus_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Entertainment': return Icons.movie_creation_rounded;
      case 'Utilities': return Icons.power_rounded;
      case 'Health': return Icons.medical_services_rounded;
      case 'Travel': return Icons.flight_takeoff_rounded;
      default: return Icons.category_rounded;
    }
  }
}
