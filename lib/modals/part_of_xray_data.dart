import 'package:cloud_firestore/cloud_firestore.dart';

class PartOfXrayData {
  final String partOfXrayName;
  final Timestamp timestamp;

  PartOfXrayData({
    required this.partOfXrayName,
    required this.timestamp,
  });

  // convert data from Firestore to a PartOfXrayData object
  factory PartOfXrayData.fromFirestore(Map<String, dynamic> data) {
    return PartOfXrayData(
      partOfXrayName: data['part_of_xray_name'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
  // Convert a PartOfXrayData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'part_of_xray_name': partOfXrayName,
      'timestamp': timestamp,
    };
  }
}
