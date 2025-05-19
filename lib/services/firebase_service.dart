import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x_ray_entry_app/modals/doctor_name_data.dart';
import 'package:x_ray_entry_app/modals/gmd_data.dart';
import 'package:x_ray_entry_app/modals/location_data.dart';
import 'package:x_ray_entry_app/modals/part_of_xray_data.dart';
import 'package:x_ray_entry_app/modals/reference_person_data.dart';
import 'package:x_ray_entry_app/modals/xray_entry_sheet_data.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService();

  // add doctor name master data to Firestore
  Future<bool> addDoctorNameData(DoctorNameData doctorNameData) async {
    try {
      await _db.collection('doctor_name_data').add(doctorNameData.toMap());
      return true;
    } catch (e) {
      print('Error adding doctor name data: $e');
      return false;
    }
  }

  // fetch doctornamedata by doctorname
  Future<DoctorNameData?> getDoctorDataByName(String doctorName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctor_name_data')
        .where('doctorName', isEqualTo: doctorName)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return DoctorNameData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all doctornames
  Future<List<DoctorNameData>> getAllDoctorNames() async {
    try {
      QuerySnapshot snapshot = await _db.collection('doctor_name_data').get();

      return snapshot.docs
          .map((doc) =>
              DoctorNameData.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all doctor names: $e');
      return [];
    }
  }

  Future<bool> updateDoctorData(int oldNo, DoctorNameData updatedData) async {
    try {
      // First check if the new no is already taken by another doctor
      if (oldNo != updatedData.no) {
        QuerySnapshot duplicateCheck = await _db
            .collection('doctor_name_data')
            .where('no', isEqualTo: updatedData.no)
            .limit(1)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print('Error: Doctor ID ${updatedData.no} already exists');
          return false;
        }
      }

      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('doctor_name_data')
          .where('no', isEqualTo: oldNo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('doctor_name_data').doc(docId).update({
          'no': updatedData.no,
          'doctorName': updatedData.doctorName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating doctor data: $e');
      return false;
    }
  }

  // add part of x-ray master data to Firestore
  Future<bool> addPartOfXrayData(PartOfXrayData partOfXrayData) async {
    try {
      await _db.collection('partOfXray').add(partOfXrayData.toMap());
      return true;
    } catch (e) {
      print('Error adding part of x-ray data: $e');
      return false;
    }
  }

  // fetch partofxraydata by partofxrayname
  Future<PartOfXrayData?> getPartOfXrayName(String partOfXray) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('partOfXray')
        .where('partOfXray', isEqualTo: partOfXray)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return PartOfXrayData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all partofxrays
  Future<List<PartOfXrayData>> getAllPartOfXrays() async {
    try {
      QuerySnapshot snapshot = await _db.collection('partOfXray').get();

      return snapshot.docs
          .map((doc) =>
              PartOfXrayData.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all partofxrays: $e');
      return [];
    }
  }

  Future<bool> updatePartOfXrayData(
      int oldNo, PartOfXrayData updatedData) async {
    try {
      // first check if the new no is already taken by another doctor
      if (oldNo != updatedData.no) {
        QuerySnapshot duplicateCheck = await _db
            .collection('partOfXray')
            .where('no', isEqualTo: updatedData.no)
            .limit(1)
            .get();
        if (duplicateCheck.docs.isNotEmpty) {
          print('Error: PartofXray ID ${updatedData.no} already exists');
          return false;
        }
      }
      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('partOfXray')
          .where('no', isEqualTo: oldNo)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('partOfXray').doc(docId).update({
          'no': updatedData.no,
          'partOfXray': updatedData.partOfXray,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating partofxray data: $e');
      return false;
    }
  }

  // add gmd master data to Firestore
  Future<bool> addGmdData(GmdData gmdData) async {
    try {
      await _db.collection('gmd_data').add(gmdData.toMap());
      return true;
    } catch (e) {
      print('Error adding gmd data: $e');
      return false;
    }
  }

  // fetch gmdData by gmdNo.
  Future<GmdData?> getGmdDataByNumber(int gmdNo) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('gmd_data')
        .where('gmd_no', isEqualTo: gmdNo)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return GmdData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all gmd Numbers
  Future<List<GmdData>> getAllGmdNumbers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('gmd_data').get();

      return snapshot.docs
          .map((doc) =>
              GmdData.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all gmd numbers: $e');
      return [];
    }
  }

  // update Gmd Master Data
  Future<bool> updateGmdData(int oldNo, GmdData updatedData) async {
    try {
      // First check if the new no is already taken by another gmd data
      if (oldNo != updatedData.gmdNo) {
        QuerySnapshot duplicateCheck = await _db
            .collection('gmd_data')
            .where('gmd_no', isEqualTo: updatedData.gmdNo)
            .limit(1)
            .get();
        if (duplicateCheck.docs.isNotEmpty) {
          print('Error. Gmd No ${updatedData.gmdNo} already exists.');
          return false;
        }
      }

      // find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('gmd_data')
          .where('gmd_no', isEqualTo: oldNo)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('gmd_data').doc(docId).update({
          'gmd_no': updatedData.gmdNo,
          'patient_name': updatedData.patientName,
          'mobile_number': updatedData.mobileNumber,
          'age': updatedData.age,
          'sex': updatedData.sex,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating gmd data: $e');
      return false;
    }
  }

  // add location master data to Firestore
  Future<bool> addLocationData(LocationData locationData) async {
    try {
      await _db.collection('location_data').add(locationData.toMap());
      return true;
    } catch (e) {
      print('Error adding location data: $e');
      return false;
    }
  }

  // fetch location name data by doctor name
  Future<LocationData?> getLocationDataByName(String locationName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('location_data')
        .where('locationName', isEqualTo: locationName)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return LocationData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all locationNames
  Future<List<LocationData>> getAllLocationNames() async {
    try {
      QuerySnapshot snapshot = await _db.collection('location_data').get();

      return snapshot.docs
          .map((doc) =>
              LocationData.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all location names: $e');
      return [];
    }
  }

  Future<bool> updateLocationData(int oldNo, LocationData updatedData) async {
    try {
      // First check if the new no is already taken by another location
      if (oldNo != updatedData.no) {
        QuerySnapshot duplicateCheck = await _db
            .collection('location_data')
            .where('no', isEqualTo: updatedData.no)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print('Error: Location ID ${updatedData.no} already exists!');
          return false;
        }
      }

      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('location_data')
          .where('no', isEqualTo: oldNo)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('location_data').doc(docId).update({
          'no': updatedData.no,
          'locationName': updatedData.locationName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating location data: $e');
      return false;
    }
  }

  // add reference person master data to Firestore
  Future<bool> addReferencePersonData(
      ReferencePersonData referencePersonData) async {
    try {
      await _db
          .collection('reference_person_data')
          .add(referencePersonData.toMap());
      return true;
    } catch (e) {
      print('Error submitting Reference Person data:');
      return false;
    }
  }

  // fetch referencepersondata by name
  Future<ReferencePersonData?> getReferencePersonDataByName(
      String referencePersonName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reference_person_data')
        .where('reference_person_name', isEqualTo: referencePersonName)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ReferencePersonData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all reference person names
  Future<List<ReferencePersonData>> getAllReferencePersonNames() async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('reference_person_data').get();

      return snapshot.docs
          .map((doc) => ReferencePersonData.fromFirestore(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching reference person names: $e');
      return [];
    }
  }

  // update reference person master
  Future<bool> updateReferencePersonData(
      int oldNo, ReferencePersonData updatedData) async {
    try {
      // first check if the new no is already taken by another reference person
      if (oldNo != updatedData.no) {
        QuerySnapshot duplicateCheck = await _db
            .collection('reference_person_data')
            .where('no', isEqualTo: updatedData.no)
            .limit(1)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print('Error: Reference Person ID ${updatedData.no} already exists!');
          return false;
        }
      }

      // find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('reference_person_data')
          .where('no', isEqualTo: oldNo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('reference_person_data').doc(docId).update({
          'no': updatedData.no,
          'reference_person_name': updatedData.referencePersonName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        print('Error: Reference Person ID $oldNo not found!');
        return false;
      }
    } catch (e) {
      print('Error updating reference person data: $e');
      return false;
    }
  }

  // add x-ray sheet data to Firestore
  Future<bool> addXrayEntrySheetData(
      XrayEntrySheetData xrayEntrySheetData) async {
    try {
      await _db.collection('xray_sheet_data').add(xrayEntrySheetData.toMap());
      return true;
    } catch (e) {
      print('Error submitting x-ray entry sheet data:');
      return false;
    }
  }
}
