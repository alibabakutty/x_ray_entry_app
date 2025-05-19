import 'package:cloud_firestore/cloud_firestore.dart';

class ReferencePersonData {
  final String referencePersonName;
  final Timestamp timestamp;

  ReferencePersonData({
    required this.referencePersonName,
    required this.timestamp,
  });

  // convert data from firestore to a ReferencePersonNameData object
  factory ReferencePersonData.fromFirestore(Map<String, dynamic> data) {
    return ReferencePersonData(
      referencePersonName: data['reference_person_name'],
      timestamp: Timestamp.now(),
    );
  }

  // convert a ReferencePersonData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'reference_person_name': referencePersonName,
      'timestamp': timestamp,
    };
  }
}
