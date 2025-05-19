import 'package:cloud_firestore/cloud_firestore.dart';

class ReferencePersonData {
  late int no;
  final String referencePersonName;
  final Timestamp timestamp;

  ReferencePersonData({
    required this.no,
    required this.referencePersonName,
    required this.timestamp,
  });

  // convert data from firestore to a ReferencePersonNameData object
  factory ReferencePersonData.fromFirestore(Map<String, dynamic> data) {
    return ReferencePersonData(
      no: data['no'] ?? 0,
      referencePersonName: data['reference_person_name'],
      timestamp: Timestamp.now(),
    );
  }

  // convert a ReferencePersonData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'reference_person_name': referencePersonName,
      'timestamp': timestamp,
    };
  }
}
