import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/models/expense_model.dart';
import 'package:expense_tracker_mobile/screens/add_expense_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Expense expense;

  const DetailsScreen({super.key, required this.expense});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Expense _currentExpense;

  @override
  void initState() {
    super.initState();
    _currentExpense = widget.expense;
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Delete Expense", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this expense?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = context.read<ApiService>();
        await api.deleteExpense(_currentExpense.id);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting expense: $e")),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true), // Return true to refresh list if we edited
        ),
        title: const Text("Expense Details", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.indigoAccent),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                // Passing as JSON because AddExpenseScreen still expects Map. 
                // TODO: Refactor AddExpenseScreen to accept Expense object.
                MaterialPageRoute(builder: (context) => AddExpenseScreen(expense: _currentExpense.toJson())),
              );
              if (updated == true && context.mounted) {
                // In a perfect world, we'd fetch the single updated expense from the API here
                // For now, since we popped with 'true', let's just pop back to Home to refresh
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                   Text(
                    _currentExpense.currency,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_currentExpense.currencySymbol} ${_currentExpense.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: _currentExpense.type == 'Credited' ? const Color(0xFF10B981) : Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard([
              _buildInfoRow(Icons.storefront_outlined, "Merchant", _currentExpense.merchant),
              const Divider(color: Colors.white12, height: 32),
              _buildInfoRow(Icons.category_outlined, "Category", _currentExpense.category),
              const Divider(color: Colors.white12, height: 32),
              _buildInfoRow(Icons.receipt_long_outlined, "Type", _currentExpense.type),
              const Divider(color: Colors.white12, height: 32),
              _buildInfoRow(Icons.calendar_today_outlined, "Date", _formatDate(_currentExpense.date)),
              const Divider(color: Colors.white12, height: 32),
              _buildInfoRow(Icons.account_balance_wallet_outlined, "Source", _currentExpense.source),
            ]),
            if (_currentExpense.notes != null && _currentExpense.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader("Notes"),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.3),
                   borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _currentExpense.notes!,
                  style: const TextStyle(color: Colors.white, height: 1.5),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.indigoAccent, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yMMMMd h:mm a').format(date);
  }
}
