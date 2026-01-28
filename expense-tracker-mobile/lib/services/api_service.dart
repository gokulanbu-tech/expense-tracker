import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator to reach localhost
  static const String baseUrl = "http://10.0.2.2:8080/api";

  Future<void> sendSmsToBackend(Map<String, dynamic> smsData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sms"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(smsData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception("Failed to sync SMS: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobile,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String email, String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/google-login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Google login failed");
    }
  }

  Future<void> signup(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  Future<List<dynamic>> getExpenses(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/expenses?userId=$userId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load expenses");
    }
  }

  Future<void> createExpense(Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/expenses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create expense: ${response.body}");
    }
  }

  Future<void> updateExpense(String id, Map<String, dynamic> expenseData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/expenses/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(expenseData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update expense: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> updateUser(String? id, Map<String, dynamic> userData) async {
    if (id == null || id.isEmpty) {
      throw Exception("User ID is missing. Please restart the app and login again.");
    }
    
    final response = await http.put(
      Uri.parse("$baseUrl/user/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }

  Future<void> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/expenses/$id"));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete expense");
    }
  }

  Future<List<dynamic>> getSuggestions() async {
    // Current web app simulates this, we'll do the same until backend is ready
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        "id": "s1",
        "title": "Cancel Unused Subscription",
        "description": "You haven't used \"Premium Music\" in 30 days.",
        "category": "Subscription",
        "potentialSavings": 199.00,
        "type": "subscription"
      },
      {
        "id": "s2",
        "title": "Coffee Habit",
        "description": "Switching to home brewing could save ₹3000/month.",
        "category": "Food",
        "potentialSavings": 3000.00,
        "type": "habit"
      }
    ];
  }

  Future<void> saveEmailLog(Map<String, dynamic> emailData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/emails"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(emailData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to sync email log: ${response.body}");
    }
  }
  Future<List<dynamic>> getBills(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/bills?userId=$userId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load bills");
    }
  }

  Future<void> createBill(Map<String, dynamic> billData) async {
    final response = await http.post(
      Uri.parse("$baseUrl/bills"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(billData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create bill: ${response.body}");
    }
  }

  Future<void> markBillAsPaid(String id) async {
    final response = await http.put(Uri.parse("$baseUrl/bills/$id/pay"));
    if (response.statusCode != 200) {
      throw Exception("Failed to mark bill as paid");
    }
  }

  Future<void> deleteBillBackend(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/bills/$id"));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete bill");
    }
  }
  Future<void> updateBill(String id, Map<String, dynamic> billData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/bills/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(billData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update bill: ${response.body}");
    }
  }
}
