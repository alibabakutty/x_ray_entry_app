import 'package:cloud_firestore/cloud_firestore.dart';

class GmdData {
  late int gmdNo;
  final String patientName;
  final String mobileNumber;
  final int age;
  final String sex;
  final Timestamp timestamp;

  GmdData({
    required this.gmdNo,
    required this.patientName,
    required this.mobileNumber,
    required this.age,
    required this.sex,
    required this.timestamp,
  });

  // convert data from Firestore to a GmdData object
  factory GmdData.fromFirestore(Map<String, dynamic> data) {
    return GmdData(
      gmdNo: data['gmd_no'] ?? 0,
      patientName: data['patient_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? 0,
      age: data['age'] ?? 0,
      sex: data['sex'] ?? '',
      timestamp: data['timestamp'],
    );
  }

  // convert GmdData object into  a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'gmd_no': gmdNo,
      'patient_name': patientName,
      'mobile_number': mobileNumber,
      'age': age,
      'sex': sex,
      'timestamp': timestamp,
    };
  }
}
