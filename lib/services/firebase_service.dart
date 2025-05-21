import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x_ray_entry_app/modals/doctor_name_data.dart';
import 'package:x_ray_entry_app/modals/executive_name_data.dart';
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
        .where('doctor_name', isEqualTo: doctorName)
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

  Future<bool> updateDoctorData(
      String oldName, DoctorNameData updatedData) async {
    try {
      // First check if the new no is already taken by another doctor
      if (oldName != updatedData.doctorName) {
        QuerySnapshot duplicateCheck = await _db
            .collection('doctor_name_data')
            .where('doctor_name', isEqualTo: updatedData.doctorName)
            .limit(1)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print('Error: Doctor Name ${updatedData.doctorName} already exists');
          return false;
        }
      }

      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('doctor_name_data')
          .where('doctor_name', isEqualTo: oldName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('doctor_name_data').doc(docId).update({
          'doctor_name': updatedData.doctorName,
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
      await _db.collection('part_of_xray_data').add(partOfXrayData.toMap());
      return true;
    } catch (e) {
      print('Error adding part of x-ray data: $e');
      return false;
    }
  }

  // fetch partofxraydata by partofxrayname
  Future<PartOfXrayData?> getPartOfXrayName(String partOfXrayName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('part_of_xray_data')
        .where('part_of_xray_name', isEqualTo: partOfXrayName)
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
      QuerySnapshot snapshot = await _db.collection('part_of_xray_data').get();

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
      String oldName, PartOfXrayData updatedData) async {
    try {
      // first check if the new no is already taken by another doctor
      if (oldName != updatedData.partOfXrayName) {
        QuerySnapshot duplicateCheck = await _db
            .collection('part_of_xray_data')
            .where('part_of_xray_name', isEqualTo: updatedData.partOfXrayName)
            .limit(1)
            .get();
        if (duplicateCheck.docs.isNotEmpty) {
          print(
              'Error: PartofXray Name ${updatedData.partOfXrayName} already exists');
          return false;
        }
      }
      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('part_of_xray_data')
          .where('part_of_xray_name', isEqualTo: oldName)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('part_of_xray_data').doc(docId).update({
          'part_of_xray_name': updatedData.partOfXrayName,
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
        .where('location_name', isEqualTo: locationName)
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

  Future<bool> updateLocationData(
      String oldName, LocationData updatedData) async {
    try {
      // First check if the new no is already taken by another location
      if (oldName != updatedData.locationName) {
        QuerySnapshot duplicateCheck = await _db
            .collection('location_data')
            .where('location_name', isEqualTo: updatedData.locationName)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print(
              'Error: Location Name ${updatedData.locationName} already exists!');
          return false;
        }
      }

      // Find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('location_data')
          .where('location_name', isEqualTo: oldName)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('location_data').doc(docId).update({
          'location_name': updatedData.locationName,
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
      String oldName, ReferencePersonData updatedData) async {
    try {
      // first check if the new no is already taken by another reference person
      if (oldName != updatedData.referencePersonName) {
        QuerySnapshot duplicateCheck = await _db
            .collection('reference_person_data')
            .where('reference_person_name',
                isEqualTo: updatedData.referencePersonName)
            .limit(1)
            .get();

        if (duplicateCheck.docs.isNotEmpty) {
          print(
              'Error: Reference Person Name ${updatedData.referencePersonName} already exists!');
          return false;
        }
      }

      // find the document by the old no
      QuerySnapshot snapshot = await _db
          .collection('reference_person_data')
          .where('reference_person_name', isEqualTo: oldName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('reference_person_data').doc(docId).update({
          'reference_person_name': updatedData.referencePersonName,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        print('Error: Reference Person Name $oldName not found!');
        return false;
      }
    } catch (e) {
      print('Error updating reference person data: $e');
      return false;
    }
  }

  // add executive name master data to firestore
  Future<bool> addExecutiveNameData(ExecutiveNameData executiveNameData) async {
    try {
      await _db
          .collection('executive_name_data')
          .add(executiveNameData.toFirestore());
      return true;
    } catch (e) {
      print('Error adding executive name data: $e');
      return false;
    }
  }

  // fetch executive name data by mobile number
  Future<ExecutiveNameData?> getExecutiveByMobileNumber(
      String mobileNumber) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('executive_name_data')
        .where('mobile_number', isEqualTo: mobileNumber)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ExecutiveNameData.fromFirestore(snapshot.docs.first.data());
    }
    return null;
  }

  // fetch all executive names
  Future<List<ExecutiveNameData>> getAllExecutiveNames() async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('executive_name_data').get();

      return snapshot.docs
          .map((doc) => ExecutiveNameData.fromFirestore(
              doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all executive names: $e');
      return [];
    }
  }

  // update executive name
  Future<bool> updateExecutiveData(
      String oldMobileNumber, ExecutiveNameData updatedData) async {
    try {
      // first check if the new no is already taken by another executive
      if (oldMobileNumber != updatedData.mobileNumber) {
        QuerySnapshot duplicateCheck = await _db
            .collection('executive_name_data')
            .where('mobile_number', isEqualTo: updatedData.mobileNumber)
            .limit(1)
            .get();
        if (duplicateCheck.docs.isNotEmpty) {
          print(
              'Error: Executive Mobile No. ${updatedData.mobileNumber} already exists');
          return false;
        }
      }

      // find the document by the old mobile no
      QuerySnapshot snapshot = await _db
          .collection('executive_name_data')
          .where('mobile_number', isEqualTo: oldMobileNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String docId = snapshot.docs.first.id;
        await _db.collection('executive_name_data').doc(docId).update({
          'executive_name': updatedData.executiveName,
          'mobile_number': updatedData.mobileNumber,
          'email': updatedData.email,
          'status': updatedData.status,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating executive data: $e');
      return false;
    }
  }

  // Collection reference
  CollectionReference get _xrayCollection => _db.collection('xray_sheet_data');

  // add x-ray sheet data to Firestore
  Future<bool> addXrayEntrySheetData(
      XrayEntrySheetData xrayEntrySheetData) async {
    try {
      await _xrayCollection.add(xrayEntrySheetData.toMap());
      return true;
    } catch (e) {
      print('Error submitting x-ray entry sheet data:');
      return false;
    }
  }

  // fetch all x-ray entries by date
  Stream<List<XrayEntrySheetData>> getAllEntries() {
    return _xrayCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XrayEntrySheetData.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  // fetch all x-ray entries by gmdnumber
  Stream<List<XrayEntrySheetData>> getEntriesByGmdNumber(int gmdNo) {
    return _xrayCollection
        .where('gmd_no', isEqualTo: gmdNo)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XrayEntrySheetData.fromFirestore(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  // fetch all x-ray entries by patientname
  Stream<List<XrayEntrySheetData>> getEntriesByPatientName(String patientName) {
    return _xrayCollection
        .where('patient_name', isEqualTo: patientName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XrayEntrySheetData.fromFirestore(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  // fetch all x-ray entries by mobilenumber
  Stream<List<XrayEntrySheetData>> getEntriesByMobileNumber(
      String mobileNumber) {
    return _xrayCollection
        .where('mobile_number', isEqualTo: mobileNumber)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XrayEntrySheetData.fromFirestore(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  // fetch entries within a date range
  Stream<List<XrayEntrySheetData>> getEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _xrayCollection
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp',
            isLessThanOrEqualTo:
                Timestamp.fromDate(endDate.add(Duration(days: 1))))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => XrayEntrySheetData.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }
}
