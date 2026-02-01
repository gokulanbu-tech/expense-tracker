import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/screens/add_bill_screen.dart';
import 'package:expense_tracker_mobile/models/bill_model.dart';

class BillDetailsScreen extends StatefulWidget {
  final Bill bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  late Bill _bill;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
  }

  Future<void> _refreshBill() async {
    // In a real app, we might fetch the specific bill by ID again
    // For now, we rely on the parent or return value to refresh
    // But since we are INSIDE the details, if we edit, we need to update state.
    // We can rely on navigator returning result.
  }

  Future<void> _markAsPaid() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      await api.markBillAsPaid(_bill.id);
      
      // Update local state by advancing date (simple optimisic update or fetch?)
      // Since backend logic is complex (frequency), better to re-fetch if possible.
      // But we don't have getBillById. 
      // Let's manually advance for UI feedback or better, pop with 'true' to refresh list.
      // The user wants to see it "Paid". 
      // Actually, if we mark as paid, the date shifts. 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bill marked as paid! Due date updated."), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Go back and refresh list
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error paying bill: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBill() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Delete Bill?", style: TextStyle(color: Colors.white)),
        content: const Text("This will remove this recurring bill permanently.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final api = context.read<ApiService>();
        await api.deleteBillBackend(_bill.id);
        if (mounted) {
           Navigator.pop(context, true); // Back to list
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting bill: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _editBill() async {
    final updated = await Navigator.push(
      context,
      // Passing as JSON until AddBillScreen is refactored
      MaterialPageRoute(builder: (context) => AddBillScreen(bill: _bill.toJson())),
    );

    if (updated == true) {
      // We need to signal up the stack, and also close this or refresh this.
      // Since we don't have getBillById, simpler to just pop back to list to refresh.
      if (mounted) {
         Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse Date
    final DateTime dueDate = _bill.dueDate;
    final DateTime? lastPaidDate = _bill.lastPaidDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final daysUntil = dueDay.difference(today).inDays;
    final bool canPay = !today.isBefore(dueDay);
    
    Color statusColor = const Color(0xFF10B981);
    String statusText = "Active";
    
    if (daysUntil < 0) {
      statusColor = Colors.redAccent;
      statusText = "Overdue by ${daysUntil.abs()} days";
    } else if (daysUntil == 0) {
      statusColor = Colors.orangeAccent;
      statusText = "Due Today";
    } else {
      statusText = "Due in $daysUntil days";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: _editBill,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: _deleteBill,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor.withOpacity(0.8), statusColor.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                   Icon(_getIconForCategory(_bill.category), color: Colors.white, size: 48),
                   const SizedBox(height: 16),
                   Text(
                     _bill.merchant,
                     style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 8),
                   Text(
                     "₹ ${_bill.amount}",
                     style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: Colors.black26,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       statusText,
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                     ),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildDetailRow(Icons.category_rounded, "Category", _bill.category),
            _buildDetailRow(Icons.repeat_rounded, "Frequency", _bill.frequency),
            _buildDetailRow(Icons.calendar_today_rounded, "Next Due Date", DateFormat('EEEE, MMM d, yyyy').format(dueDate)),
            if (lastPaidDate != null)
              _buildDetailRow(Icons.history_rounded, "Last Paid", DateFormat('MMM d, yyyy').format(lastPaidDate)),
            if (_bill.note != null && _bill.note!.isNotEmpty)
              _buildDetailRow(Icons.note_alt_rounded, "Note", _bill.note!),
            
            const SizedBox(height: 40),
            
            // Actions
            if (!_isLoading) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canPay ? _markAsPaid : null,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(canPay ? "Mark as Paid" : "Payable on ${DateFormat('MMM d').format(dueDate)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white10,
                    disabledForegroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              if (!canPay)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: Text("You can only pay this bill on or after the due date.", style: TextStyle(color: Colors.grey, fontSize: 12))),
                ),
            ],
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
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
      case 'Investment': return Icons.trending_up_rounded;
      default: return Icons.category_rounded;
    }
  }
}
