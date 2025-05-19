import 'package:cloud_firestore/cloud_firestore.dart';

class LocationData {
  final String locationName;
  final Timestamp timestamp;

  LocationData({
    required this.locationName,
    required this.timestamp,
  });

  // convert data from Firestore to a LocationData object
  factory LocationData.fromFirestore(Map<String, dynamic> data) {
    return LocationData(
      locationName: data['location_name'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // convert a LocationData object into a Map object for Firebase
  Map<String, dynamic> toMap() {
    return {
      'location_name': locationName,
      'timestamp': timestamp,
    };
  }
}
