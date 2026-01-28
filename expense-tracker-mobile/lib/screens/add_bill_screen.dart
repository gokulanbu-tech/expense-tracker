import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker_mobile/services/api_service.dart';
import 'package:expense_tracker_mobile/providers/user_provider.dart';
import 'package:intl/intl.dart';

class AddBillScreen extends StatefulWidget {
  final Map<String, dynamic>? bill; // Optional for edit mode

  const AddBillScreen({super.key, this.bill});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedCategory = 'Utilities';
  late DateTime _selectedDate;
  bool _isLoading = false;
  String _frequency = 'MONTHLY';
  bool _isEditing = false;

  final List<String> _categories = [
    'Utilities', 'Entertainment', 'Food', 'Shopping', 
    'Health', 'Transport', 'Travel', 'Investment', 'General'
  ];
  
  final List<String> _frequencies = ['MONTHLY', 'WEEKLY', 'YEARLY'];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _isEditing = true;
      _merchantController.text = widget.bill!['merchant'] ?? '';
      _amountController.text = (widget.bill!['amount'] ?? 0).toString();
      _noteController.text = widget.bill!['note'] ?? '';
      _selectedCategory = widget.bill!['category'] ?? 'Utilities';
      _frequency = widget.bill!['frequency'] ?? 'MONTHLY';
      _selectedDate = DateTime.parse(widget.bill!['dueDate']);
      
      if (!_categories.contains(_selectedCategory)) {
        _categories.add(_selectedCategory);
      }
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      final api = context.read<ApiService>();
      
      final billData = {
        "user": {"id": user?['id']},
        "merchant": _merchantController.text,
        "amount": double.parse(_amountController.text),
        "category": _selectedCategory,
        "note": _noteController.text,
        "dueDate": _selectedDate.toIso8601String(),
        "frequency": _frequency,
        "type": "Debit", 
      };
      
      if (_isEditing) {
        await api.updateBill(widget.bill!['id'], billData);
      } else {
        await api.createBill(billData);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? "Bill updated!" : "Bill added successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving bill: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
         return Theme(
           data: Theme.of(context).copyWith(
             colorScheme: const ColorScheme.dark(
               primary: Color(0xFF6366F1),
               onPrimary: Colors.white,
               surface: Color(0xFF1E293B),
               onSurface: Colors.white,
             ),
           ),
           child: child!,
         );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Bill" : "Add New Bill"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               _buildTextField(
                 controller: _merchantController,
                 label: "Merchant / Service Name",
                 icon: Icons.store_rounded,
                 validator: (val) => val == null || val.isEmpty ? "Required" : null,
               ),
               const SizedBox(height: 16),
               Row(
                 children: [
                   Expanded(
                     child: _buildTextField(
                       controller: _amountController,
                       label: "Amount (₹)",
                       icon: Icons.currency_rupee_rounded,
                       keyboardType: TextInputType.number,
                       validator: (val) {
                         if (val == null || val.isEmpty) return "Required";
                         if (double.tryParse(val) == null) return "Invalid";
                         return null;
                       },
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 16),
               
               // Category Dropdown
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 decoration: BoxDecoration(
                   color: const Color(0xFF1E293B),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.white10),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: _selectedCategory,
                     dropdownColor: const Color(0xFF1E293B),
                     style: const TextStyle(color: Colors.white),
                     icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                     isExpanded: true,
                     items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                     onChanged: (val) => setState(() => _selectedCategory = val!),
                   ),
                 ),
               ),
               
               const SizedBox(height: 16),
               
                // Frequency Dropdown
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 decoration: BoxDecoration(
                   color: const Color(0xFF1E293B),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.white10),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: _frequency,
                     dropdownColor: const Color(0xFF1E293B),
                     style: const TextStyle(color: Colors.white),
                     icon: const Icon(Icons.repeat_rounded, color: Colors.white70),
                     isExpanded: true,
                     items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                     onChanged: (val) => setState(() => _frequency = val!),
                   ),
                 ),
               ),
               
               const SizedBox(height: 16),
               
               InkWell(
                 onTap: _pickDate,
                 child: Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: const Color(0xFF1E293B),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.white10),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.calendar_today_rounded, color: Color(0xFF6366F1)),
                       const SizedBox(width: 12),
                       Text(
                         "Due Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
                         style: const TextStyle(color: Colors.white, fontSize: 16),
                       ),
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: 16),
               
               _buildTextField(
                 controller: _noteController,
                 label: "Note (Optional)",
                 icon: Icons.note_alt_outlined,
                 maxLines: 2,
               ),
               
               const SizedBox(height: 32),
               
               ElevatedButton(
                 onPressed: _isLoading ? null : _saveBill,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF6366F1),
                   padding: const EdgeInsets.all(16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditing ? "Update Bill" : "Create Bill", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
