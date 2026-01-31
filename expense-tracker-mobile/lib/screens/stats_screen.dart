import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  List<Expense> _expenses = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  
  // New Data Structures
  Map<int, double> _monthlyTrendData = {}; // Month Index -> Amount
  List<MapEntry<String, double>> _topMerchants = [];
  double _dailyAverage = 0;
  double _savingsRate = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      final api = context.read<ApiService>();
      if (user != null) {
        final data = await api.getExpenses(user.id);
        
        double income = 0;
        double expense = 0;
        Map<String, double> merchantMap = {};
        Map<int, double> monthMap = {};
        
        final now = DateTime.now();
        final startOfPeriod = DateTime(now.year, now.month - 5, 1); // Last 6 months

        for (var item in data) {
           final amount = item.amount;
           final type = item.type.toLowerCase();
           final date = item.date;
           
           if (type == 'credited') {
             income += amount;
           } else {
             expense += amount;
             
             // Merchant Aggregation
             final merchant = item.merchant;
             merchantMap[merchant] = (merchantMap[merchant] ?? 0) + amount;
             
             // Monthly Trend Aggregation (only expenses)
             if (date.isAfter(startOfPeriod.subtract(const Duration(days: 1)))) {
               // We use month index as key (1-12)
               // This implies we handle year wraparounds loosely for this simple view or assume logic allows it.
               // Better: Store by absolute month index (Year * 12 + Month) to handle transitions
               int key = date.month; 
               monthMap[key] = (monthMap[key] ?? 0) + amount;
             }
           }
        }
        
        // Calculate Metrics
        double savings = income > 0 ? ((income - expense) / income * 100) : 0;
        double dailyAvg = expense > 0 ? (expense / 30) : 0; // Simplified for "This Month" approximation or active period

        // Top Merchants
        final sortedMerchants = merchantMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
          
        setState(() {
          _expenses = data;
          _totalIncome = income;
          _totalExpense = expense;
          _monthlyTrendData = monthMap;
          _topMerchants = sortedMerchants.take(5).toList();
          _savingsRate = savings;
          _dailyAverage = dailyAvg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text("Analytics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyMetricsCards(),
                const SizedBox(height: 24),
                _buildIncomeVsExpenseCard(),
                const SizedBox(height: 24),
                _buildMonthlyTrendChart(),
                const SizedBox(height: 24),
                _buildTopMerchantsList(),
              ],
            ),
          ),
    );
  }
  
  Widget _buildKeyMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "Savings Rate", 
            "${_savingsRate.toStringAsFixed(1)}%", 
            _savingsRate > 20 ? Colors.greenAccent : Colors.orangeAccent,
            Icons.savings_outlined
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Daily Average", 
            "₹${_dailyAverage.toStringAsFixed(0)}", 
            Colors.blueAccent,
            Icons.trending_up
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopMerchantsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Who Gets My Money?",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
          ),
          child: Column(
            children: _topMerchants.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.storefront, color: Colors.indigoAccent, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${entry.value.toStringAsFixed(0)}", 
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart() {
    final now = DateTime.now();
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;
    
    // Generate data for last 6 months
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthIndex = date.month; // 1-12
      final value = _monthlyTrendData[monthIndex] ?? 0;
      if (value > maxY) maxY = value;
      
      barGroups.add(
        BarChartGroupData(
          x: i, // 0 to 5, where 5 is current month
          barRods: [
             BarChartRodData(
              toY: value,
              color: const Color(0xFFA855F7),
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY > 0 ? maxY * 1.2 : 100,
                color: const Color(0xFF334155).withOpacity(0.3),
              ),
            ),
          ]
        )
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Trend (Last 6 Months)",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: maxY > 0 ? maxY * 1.2 : 100,
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
                        final date = DateTime(now.year, now.month - (5 - value.toInt()), 1);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM').format(date), 
                            style: const TextStyle(color: Colors.grey, fontSize: 10)
                          ),
                        );
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
      ),
    );
  }

  Widget _buildIncomeVsExpenseCard() {
    // 1. Prepare Data for Bar Chart
    // We will show 2 bars: Income vs Expense
    final maxVal = (_totalIncome > _totalExpense ? _totalIncome : _totalExpense);
    final topY = maxVal > 0 ? maxVal * 1.2 : 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text(
            "Income vs Expense",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topY,
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
                        String text = '';
                        if (value == 0) text = 'Income';
                        if (value == 1) text = 'Expense';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true, 
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _totalIncome,
                        color: const Color(0xFF10B981),
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: topY,
                          color: const Color(0xFF334155).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _totalExpense,
                        color: const Color(0xFFEF4444),
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: topY,
                          color: const Color(0xFF334155).withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _buildLegendItem("Income", _totalIncome, const Color(0xFF10B981)),
               _buildLegendItem("Expense", _totalExpense, const Color(0xFFEF4444)),
             ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "₹ ${value.toStringAsFixed(0)}",
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
