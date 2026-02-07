import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/bill_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final List<Bill> bills;
  final Function(String, String) onPay;

  const CalendarScreen({super.key, required this.bills, required this.onPay});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  List<Bill> _getBillsForDay(DateTime day) {
    return widget.bills.where((bill) {
      return isSameDay(bill.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final billsForSelectedDay = _getBillsForDay(_selectedDay);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: _getBillsForDay,
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Color(0xFF6366F1), // Indigo marker
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFF334155), // Slate for today
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6366F1), // Indigo for selected
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(color: Colors.white),
            weekendTextStyle: TextStyle(color: Colors.white70),
            outsideTextStyle: TextStyle(color: Colors.grey),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
            leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              final bills = events.cast<Bill>();
              // Check if any is unpaid (Red dot) else all paid (Green dot)
              // Since we don't have isPaid on frontend firmly yet, we use dueDate logic
              // Or if you passed isPaid from backend, use that.
              // For now, let's just show a dot count.
              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: bills.map((bill) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCategoryColor(bill.category),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Due on ${DateFormat('MMM d').format(_selectedDay)}",
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (billsForSelectedDay.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        "No bills due on this day.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: billsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final bill = billsForSelectedDay[index];
                        return _buildCompactBillCard(bill);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBillCard(Bill bill) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(bill.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIconForCategory(bill.category),
                size: 20, color: _getCategoryColor(bill.category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.merchant,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹ ${bill.amount}",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
                 // Check logic: pay only if due?
                 final now = DateTime.now();
                 final today = DateTime(now.year, now.month, now.day);
                 final dueDay = DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
                 
                 if (today.isBefore(dueDay)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Due on ${DateFormat('MMM d').format(bill.dueDate)}"), backgroundColor: Colors.orange),
                    );
                    return;
                 }
                 widget.onPay(bill.id, bill.merchant);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(60, 30),
            ),
            child: const Text("Pay", style: TextStyle(fontSize: 10)),
          )
        ],
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
      case 'Investment': return Colors.tealAccent;
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
      case 'Investment': return Icons.trending_up_rounded;
      default: return Icons.category_rounded;
    }
  }
}
