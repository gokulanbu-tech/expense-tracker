import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = 'Food';
  String _selectedType = 'Purchase';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = ['Food', 'Transport', 'Utilities', 'Shopping', 'Entertainment', 'Health', 'Travel'];
  final List<String> _types = ['Purchase', 'Transfer', 'Withdrawal', 'BillPayment'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!['amount'].toString();
      _merchantController.text = widget.expense!['merchant'] ?? "";
      _notesController.text = widget.expense!['notes'] ?? "";
      _selectedCategory = widget.expense!['category'] ?? 'Food';
      _selectedType = widget.expense!['type'] ?? 'Purchase';
      _selectedDate = DateTime.parse(widget.expense!['date']);
    } else {
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _merchantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      final api = context.read<ApiService>();

      final expenseData = {
        "amount": double.parse(_amountController.text),
        "currency": "INR",
        "merchant": _merchantController.text,
        "category": _selectedCategory,
        "type": _selectedType,
        "date": _selectedDate.toIso8601String(),
        "source": widget.expense?['source'] ?? "Manual",
        "notes": _notesController.text,
        "user": {"id": user?['id']}
      };

      if (widget.expense != null) {
        await api.updateExpense(widget.expense!['id'].toString(), expenseData);
      } else {
        await api.createExpense(expenseData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving expense: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.expense != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? "Edit Expense" : "Add Expense", style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Amount",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "₹",
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                    ),
                    autofocus: !isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Transaction Type"),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _types.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type);
                    },
                    selectedColor: const Color(0xFF6366F1),
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(color: _selectedType == type ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField("Merchant / Title", _merchantController, Icons.storefront_outlined),
            const SizedBox(height: 24),
            _buildCategoryPicker(),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildTextField("Notes (Optional)", _notesController, Icons.notes_rounded, maxLines: 3),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEditing ? "Update Expense" : "Save Expense", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.indigoAccent),
            filled: true,
            fillColor: const Color(0xFF1E293B).withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Category"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              )).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Date"),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.indigoAccent),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yMMMMd').format(_selectedDate),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
