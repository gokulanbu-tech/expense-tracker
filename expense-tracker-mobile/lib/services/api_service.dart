import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../models/bill_model.dart';

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

  Future<User> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": mobile,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed");
    }
  }

  Future<User> loginWithGoogle(String email, String firstName, String lastName) async {
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
      return User.fromJson(jsonDecode(response.body));
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

  Future<List<Expense>> getExpenses(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/expenses?userId=$userId"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Expense.fromJson(item)).toList();
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

  Future<User> updateUser(String? id, Map<String, dynamic> userData) async {
    if (id == null || id.isEmpty) {
      throw Exception("User ID is missing. Please restart the app and login again.");
    }
    
    final response = await http.put(
      Uri.parse("$baseUrl/user/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
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

  Future<List<dynamic>> getSuggestions(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/suggestions?userId=$userId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load insights: ${response.statusCode}");
    }
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
  Future<List<Bill>> getBills(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/bills?userId=$userId"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Bill.fromJson(item)).toList();
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
  Future<Map<String, dynamic>> sendMessage(String userId, String message, {List<String>? history}) async {
    final body = {
      "message": message,
      "history": history ?? [],
    };

    final response = await http.post(
      Uri.parse("$baseUrl/chat/ask?userId=$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  Future<int> getChatStatus(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/chat/status?userId=$userId"));
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception("Failed to get chat status");
    }
  }
}

