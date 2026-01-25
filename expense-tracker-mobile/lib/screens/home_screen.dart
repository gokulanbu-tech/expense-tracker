import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/screens/details_screen.dart';
import 'package:expense_tracker_mobile/screens/add_expense_screen.dart';
import 'package:expense_tracker_mobile/screens/suggestions_screen.dart';
import 'package:expense_tracker_mobile/screens/profile_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedTimeframe = 'Monthly';
  List<dynamic> _allExpenses = [];
  List<dynamic> _filteredExpenses = [];
  bool _isLoading = true;
  double _totalAmount = 0;

  final List<String> _timeframes = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      final api = context.read<ApiService>();
      if (user != null) {
        final data = await api.getExpenses(user['id']);
        setState(() {
          _allExpenses = data;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading expenses: $e")),
        );
      }
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    setState(() {
      _filteredExpenses = _allExpenses.where((expense) {
        final date = DateTime.parse(expense['date']);
        final expenseDate = DateTime(date.year, date.month, date.day);
        
        switch (_selectedTimeframe) {
          case 'Daily':
            return expenseDate.isAtSameMomentAs(today);
          case 'Weekly':
            final weekStart = today.subtract(Duration(days: now.weekday - 1));
            return expenseDate.isAtSameMomentAs(weekStart) || expenseDate.isAfter(weekStart);
          case 'Monthly':
            return date.month == now.month && date.year == now.year;
          case 'Yearly':
            return date.year == now.year;
          default:
            return true;
        }
      }).toList();
      _totalAmount = _filteredExpenses.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(user),
          const Center(child: Text("Wallet - Coming Soon", style: TextStyle(color: Colors.white))),
          const SizedBox.shrink(), // Center button placeholder
          const SuggestionsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          if (index == 2) {
            final added = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            );
            if (added == true) _fetchExpenses();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic>? user) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchExpenses,
        color: const Color(0xFF6366F1),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome back,",
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user?['firstName'] ?? "User",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.sync_rounded, color: Colors.white),
                              onPressed: () async {
                                await context.read<UserProvider>().syncEmails();
                                _fetchExpenses();
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Expenses",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹ ${_totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedTimeframe == 'Monthly') ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 _InfoTile(
                                   label: "Budget", 
                                   value: "₹ ${((user?['monthlyBudget'] ?? 0.0) as num).toStringAsFixed(0)}"
                                 ),
                                 _InfoTile(
                                   label: "Remaining", 
                                   value: "₹ ${(((user?['monthlyBudget'] ?? 0.0) as num) - _totalAmount).toStringAsFixed(0)}"
                                 ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Timeframe Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _timeframes.map((tf) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tf),
                            selected: _selectedTimeframe == tf,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedTimeframe = tf);
                                _applyFilter();
                              }
                            },
                            selectedColor: const Color(0xFF6366F1),
                            backgroundColor: const Color(0xFF1E293B),
                            labelStyle: TextStyle(
                              color: _selectedTimeframe == tf ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_filteredExpenses.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPieChart()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildChartLegend()),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("See All"),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
              )
            else if (_filteredExpenses.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("No expenses for this period", style: TextStyle(color: Colors.grey))),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = _filteredExpenses[index];
                    return InkWell(
                      onTap: () async {
                         final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailsScreen(expense: expense)),
                        );
                        if (updated == true) _fetchExpenses();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                              child: Icon(_getIconForCategory(expense['category']), color: Colors.indigoAccent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense['merchant'] ?? "Unknown",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    expense['category'] ?? "General",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "- ₹ ${expense['amount']}",
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _filteredExpenses.length,
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final Map<String, double> categoryData = {};
    for (var expense in _filteredExpenses) {
      final category = expense['category'] ?? 'Other';
      categoryData[category] = (categoryData[category] ?? 0) + (expense['amount'] as num).toDouble();
    }

    final sections = categoryData.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '',
        radius: 40,
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildChartLegend() {
    final Map<String, double> categoryData = {};
    for (var expense in _filteredExpenses) {
      final category = expense['category'] ?? 'Other';
      categoryData[category] = (categoryData[category] ?? 0) + (expense['amount'] as num).toDouble();
    }

    final topCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: topCategories.take(3).map((entry) {
        final percentage = (entry.value / (_totalAmount > 0 ? _totalAmount : 1) * 100).toStringAsFixed(0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getCategoryColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Text(
                "$percentage%",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFF6366F1);
      case 'Transport': return const Color(0xFFA855F7);
      case 'Shopping': return const Color(0xFFEC4899);
      case 'Entertainment': return const Color(0xFFF59E0B);
      case 'Utilities': return const Color(0xFF10B981);
      case 'Health': return const Color(0xFFEF4444);
      case 'Travel': return const Color(0xFF06B6D4);
      default: return Colors.grey;
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

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
