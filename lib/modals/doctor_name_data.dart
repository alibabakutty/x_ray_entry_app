import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorNameData {
  late int no;
  final String doctorName;
  final Timestamp timestamp;

  DoctorNameData({
    required this.no,
    required this.doctorName,
    required this.timestamp,
  });

  // convert data from Firestore to a DoctorNameData object
  factory DoctorNameData.fromFirestore(Map<String, dynamic> data) {
    return DoctorNameData(
      no: data['no'] ?? 0,
      doctorName: data['doctorName'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convert a DoctorNameData object into a Map object for Firebase
  // This is used to store the data in Firestore
  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'doctorName': doctorName,
      'timestamp': timestamp,
    };
  }
}
