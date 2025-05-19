import 'package:cloud_firestore/cloud_firestore.dart';

class LocationData {
  late int no;
  final String locationName;
  final Timestamp timestamp;

  LocationData({
    required this.no,
    required this.locationName,
    required this.timestamp,
  });

  // convert data from Firestore to a LocationData object
  factory LocationData.fromFirestore(Map<String, dynamic> data) {
    return LocationData(
      no: data['no'] ?? 0,
      locationName: data['locationName'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // convert a LocationData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'locationName': locationName,
      'timestamp': timestamp,
    };
  }
}
