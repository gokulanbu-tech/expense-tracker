
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final double monthlyBudget;
  final String currency;
  final bool darkMode;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.monthlyBudget,
    required this.currency,
    required this.darkMode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      monthlyBudget: (json['monthlyBudget'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'monthlyBudget': monthlyBudget,
      'currency': currency,
      'darkMode': darkMode,
    };
  }
}
