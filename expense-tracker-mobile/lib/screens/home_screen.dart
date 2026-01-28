import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/screens/details_screen.dart';
import 'package:expense_tracker_mobile/screens/add_expense_screen.dart';
import 'package:expense_tracker_mobile/screens/suggestions_screen.dart';
import 'package:expense_tracker_mobile/screens/profile_screen.dart';
import 'package:expense_tracker_mobile/screens/all_expenses_screen.dart';
import 'package:expense_tracker_mobile/screens/stats_screen.dart';
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
  double _totalAmount = 0; // Interpreted as Expenses
  double _totalIncome = 0;
  bool _isSyncing = false;

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
        // Sort by date descending
        data.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        
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
            return expenseDate.year == today.year && 
                   expenseDate.month == today.month && 
                   expenseDate.day == today.day;
          case 'Weekly':
            // Logic for start of week (e.g., Monday)
            final weekStart = today.subtract(Duration(days: today.weekday - 1));
            final weekEnd = weekStart.add(Duration(days: 6));
            return expenseDate.isAfter(weekStart.subtract(Duration(seconds: 1))) && 
                   expenseDate.isBefore(weekEnd.add(Duration(days: 1)));
          case 'Monthly':
            return date.month == now.month && date.year == now.year;
          case 'Yearly':
            return date.year == now.year;
          default:
            return true;
        }
      }).toList();
      
      _totalAmount = 0;
      _totalIncome = 0;
      
      for (var item in _filteredExpenses) {
        final amount = (item['amount'] as num).toDouble();
        final type = item['type']?.toString().toLowerCase();
        
        if (type == 'credited') {
          _totalIncome += amount;
        } else {
          _totalAmount += amount;
        }
      }
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
                                onPressed: _isSyncing ? null : () async {
                                  setState(() => _isSyncing = true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Syncing emails...")),
                                  );
                                  await context.read<UserProvider>().syncEmails();
                                  await _fetchExpenses();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Sync complete!", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF10B981)),
                                    );
                                  }
                                  setState(() => _isSyncing = false);
                                },
                              ),
                              if (_isSyncing)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 16, 
                                    height: 16, 
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                  ),
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
                                 if (_totalIncome > 0)
                                 _InfoTile(
                                   label: "Income", 
                                   value: "₹ ${_totalIncome.toStringAsFixed(0)}"
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
            if (_filteredExpenses.isNotEmpty && _selectedTimeframe != 'Daily')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
                    ),
                    child: _buildTimeChart(),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllExpensesScreen(expenses: _filteredExpenses),
                          ),
                        );
                      },
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
                              "${(expense['type'].toString().toLowerCase() == 'credited') ? '+' : '-'} ₹ ${expense['amount']}",
                              style: TextStyle(
                                color: (expense['type'].toString().toLowerCase() == 'credited') ? const Color(0xFF10B981) : Colors.redAccent,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _filteredExpenses.length > 5 ? 5 : _filteredExpenses.length,
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
      if (expense['type']?.toString().toLowerCase() == 'credited') continue;
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

  Widget _buildTimeChart() {
    // 1. Aggregate Data
    Map<int, double> timeData = {};
    int maxKey = 0;
    
    for (var expense in _filteredExpenses) {
      if (expense['type']?.toString().toLowerCase() == 'credited') continue;
      
      final date = DateTime.parse(expense['date']);
      int key = 0;
      
      if (_selectedTimeframe == 'Weekly') {
        key = date.weekday; // 1=Mon, 7=Sun
        maxKey = 7;
      } else if (_selectedTimeframe == 'Monthly') {
        key = date.day; // 1..31
        maxKey = 31;
      } else if (_selectedTimeframe == 'Yearly') {
        key = date.month; // 1..12
        maxKey = 12;
      }
      
      timeData[key] = (timeData[key] ?? 0) + (expense['amount'] as num).toDouble();
    }

    // 2. Prepare Spots
    List<BarChartGroupData> barGroups = [];
    double maxAmount = 0;
    
    for (int i = 1; i <= maxKey; i++) {
        double val = timeData[i] ?? 0;
        if (val > maxAmount) maxAmount = val;
        
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: val,
                color: const Color(0xFF6366F1),
                width: _selectedTimeframe == 'Monthly' ? 4 : 12, // Thinner bars for monthly
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxAmount > 0 ? maxAmount * 1.2 : 100,
                  color: const Color(0xFF334155).withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Overall Spending Trend (${_selectedTimeframe})",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: maxAmount > 0 ? maxAmount * 1.2 : 100,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: const Color(0xFF1E293B),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '₹${rod.toY.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (_selectedTimeframe == 'Monthly') {
                         if (value % 5 != 0) return const SizedBox.shrink(); // Show every 5th day
                         return Text('${value.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 10));
                      }
                      
                      String text = '';
                      if (_selectedTimeframe == 'Weekly') {
                         const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                         if (value >= 1 && value <= 7) text = days[value.toInt() - 1];
                      } else if (_selectedTimeframe == 'Yearly') {
                         const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                         if (value >= 1 && value <= 12) text = months[value.toInt() - 1];
                      }
                      return Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend() {
    final Map<String, double> categoryData = {};
    for (var expense in _filteredExpenses) {
      if (expense['type']?.toString().toLowerCase() == 'credited') continue;
      final category = expense['category'] ?? 'Other';
      categoryData[category] = (categoryData[category] ?? 0) + (expense['amount'] as num).toDouble();
    }

    final totalAll = categoryData.values.fold(0.0, (sum, val) => sum + val);

    final topCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: topCategories.take(3).map((entry) {
        double percentVal = (entry.value / (totalAll > 0 ? totalAll : 1) * 100);
        String percentage;
        if (percentVal > 0 && percentVal < 0.1) {
          percentage = "< 0.1";
        } else {
          percentage = percentVal.toStringAsFixed(1);
        }
        
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
