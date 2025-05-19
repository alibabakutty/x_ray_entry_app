import 'package:decimal/decimal.dart';

class XrayEntrySheetData {
  final String partOfXray;
  final int gmdNo;
  final String patientName;
  final String mobileNumber;
  final int age;
  final String sex;
  final String doctorName;
  final String paymentType;
  final String locationName;
  final Decimal referenceFee;
  final String referencePersonName;
  final String paidOrDue;

  XrayEntrySheetData({
    required this.partOfXray,
    required this.gmdNo,
    required this.patientName,
    required this.mobileNumber,
    required this.age,
    required this.sex,
    required this.doctorName,
    required this.paymentType,
    required this.locationName,
    required this.referenceFee,
    required this.referencePersonName,
    required this.paidOrDue,
  });

  // convert data from Firestore to a XrayEntrySheetData object
  factory XrayEntrySheetData.fromFirestore(Map<String, dynamic> data) {
    return XrayEntrySheetData(
      partOfXray: data['partOfXray'] ?? '',
      gmdNo: data['gmd_no'] ?? 0,
      patientName: data['patient_name'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      age: data['age'] ?? 0,
      sex: data['sex'] ?? '',
      doctorName: data['doctorName'] ?? '',
      paymentType: data['payment_type'] ?? '',
      locationName: data['location_name'] ?? '',
      referenceFee: Decimal.parse((data['reference_fee'] ?? 0.0).toString()),
      referencePersonName: data['referencePersonName'] ?? '',
      paidOrDue: data['paid_or_due'] ?? '',
    );
  }

  // This is used to store the data into firestore
  Map<String, dynamic> toMap() {
    return {
      'partOfXray': partOfXray,
      'gmd_no': gmdNo,
      'patient_name': patientName,
      'mobile_number': mobileNumber,
      'age': age,
      'sex': sex,
      'doctorName': doctorName,
      'payment_type': paymentType,
      'location_name': locationName,
      'reference_fee': referenceFee.toDouble(), // convert decimal to double
      'referencePersonName': referencePersonName,
      'paid_or_due': paidOrDue,
    };
  }
}
