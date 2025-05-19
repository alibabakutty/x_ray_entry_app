import 'package:cloud_firestore/cloud_firestore.dart';

class PartOfXrayData {
  late int no;
  final String partOfXray;
  final Timestamp timestamp;

  PartOfXrayData({
    required this.no,
    required this.partOfXray,
    required this.timestamp,
  });

  // convert data from Firestore to a PartOfXrayData object
  factory PartOfXrayData.fromFirestore(Map<String, dynamic> data) {
    return PartOfXrayData(
      no: data['no'] ?? 0,
      partOfXray: data['partOfXray'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
  // Convert a PartOfXrayData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'partOfXray': partOfXray,
      'timestamp': timestamp,
    };
  }
}
