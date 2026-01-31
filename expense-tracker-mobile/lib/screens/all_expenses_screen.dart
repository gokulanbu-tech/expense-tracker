import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/screens/details_screen.dart';
import 'package:expense_tracker_mobile/models/expense_model.dart';

class AllExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;

  const AllExpensesScreen({super.key, required this.expenses});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  late List<Expense> _expenses;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
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
          onPressed: () => Navigator.pop(context, _hasChanged),
        ),
        title: const Text("All Transactions", style: TextStyle(color: Colors.white)),
      ),
      body: _expenses.isEmpty
          ? const Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return InkWell(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(expense: expense),
                      ),
                    );
                    
                    if (updated == true) {
                      setState(() {
                        _hasChanged = true;
                        // Since we don't know if it was edit or delete, and we don't have API fetch here easily,
                        // We will just remove it for now to avoid stale data if deleted.
                        // If edited, removing is weird.
                        // Ideally we should re-fetch or pass the updated object back.
                        // But since we want to trigger Home refresh anyway, let's just Pop back to Home immediately?
                        // Or just remove from list to be safe.
                        // Actually, if we delete, we remove. If edit, we might show stale unless we pass back object.
                        // Let's assume delete for now or just pop to refresh.
                        
                        // Simplest robust solution: If something changed, return to Home to refresh everything.
                        Navigator.pop(context, true);
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getIconForCategory(expense.category), color: Colors.indigoAccent),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.merchant,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _formatDate(expense.date),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${(expense.type.toLowerCase() == 'credited') ? '+' : '-'} ${expense.currencySymbol} ${expense.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: (expense.type.toLowerCase() == 'credited')
                                    ? const Color(0xFF10B981)
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                             Text(
                                expense.category,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
      default: return Icons.category_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}
