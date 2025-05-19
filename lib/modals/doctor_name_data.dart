import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorNameData {
  final String doctorName;
  final Timestamp timestamp;

  DoctorNameData({
    required this.doctorName,
    required this.timestamp,
  });

  // convert data from Firestore to a DoctorNameData object
  factory DoctorNameData.fromFirestore(Map<String, dynamic> data) {
    return DoctorNameData(
      doctorName: data['doctor_name'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert a DoctorNameData object into a Map object for Firebase
  // This is used to store the data in Firestore
  Map<String, dynamic> toMap() {
    return {
      'doctor_name': doctorName,
      'timestamp': timestamp,
    };
  }
}
