import 'package:cloud_firestore/cloud_firestore.dart';

class ExecutiveNameData {
  final String executiveName;
  final String mobileNumber;
  final String email;
  final String password;
  final String status; // active or inactive
  final Timestamp timestamp;

  ExecutiveNameData({
    required this.executiveName,
    required this.mobileNumber,
    required this.email,
    required this.password,
    this.status = 'active',
    required this.timestamp,
  });

  // convert data from Firestore
  factory ExecutiveNameData.fromFirestore(Map<String, dynamic> data) {
    return ExecutiveNameData(
      executiveName: data['executive_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      status: data['status'] ?? 'active',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // convert a executivenamedata object into a map object for firebase
  Map<String, dynamic> toFirestore() {
    return {
      'executive_name': executiveName,
      'mobile_number': mobileNumber,
      'email': email,
      'password': password,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
