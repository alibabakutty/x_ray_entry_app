import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  bool _isLoading = false;
  String _statusMessage = '';
  bool _hasError = false;
  int _successCount = 0;
  int _errorCount = 0;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Selecting Excel file...';
      _hasError = false;
      _successCount = 0;
      _errorCount = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'No file selected';
        });
        return;
      }

      Uint8List bytes;
      final file = result.files.single;

      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Failed to read file content';
          _hasError = true;
        });
        return;
      }

      final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
      final table = decoder.tables.values.first;

      if (table.rows.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'No data found in Excel sheet';
          _hasError = true;
        });
        return;
      }

      final batch = _firestore.batch();
      final collectionRef = _firestore.collection('xray_sheet_data');

      for (int i = 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          if (row.length < 12) {
            _errorCount++;
            continue;
          }

          final gmdNo = _parseInt(row[1]);
          if (gmdNo == null || gmdNo <= 0) {
            _errorCount++;
            continue;
          }

          final partOfXray = _parseString(row[0]);
          final patientName = _parseString(row[2]);
          final mobileNumber = _parseString(row[3]);
          final age = _parseInt(row[4]) ?? 0;
          final sex = _parseString(row[5]);
          final doctorName = _parseString(row[6]);
          final paymentType = _parseString(row[7]);
          final locationName = _parseString(row[8]);
          final referenceFee = Decimal.parse(_parseDouble(row[9]).toString());
          final referencePersonName = _parseString(row[10]);
          final paidOrDue = _parseString(row[11]);

          Timestamp timestamp;
          if (row.length > 12 && row[12] != null) {
            try {
              final dateStr = row[12].toString();
              timestamp =
                  Timestamp.fromDate(DateFormat('dd/MM/yyyy').parse(dateStr));
            } catch (_) {
              timestamp = Timestamp.now();
            }
          } else {
            timestamp = Timestamp.now();
          }

          final entry = XrayEntrySheetData(
            partOfXray: partOfXray,
            gmdNo: gmdNo,
            patientName: patientName,
            mobileNumber: mobileNumber,
            age: age,
            sex: sex,
            doctorName: doctorName,
            paymentType: paymentType,
            locationName: locationName,
            referenceFee: referenceFee,
            referencePersonName: referencePersonName,
            paidOrDue: paidOrDue,
            timestamp: timestamp,
          );

          batch.set(collectionRef.doc(), entry.toMap());
          _successCount++;

          if (i % 10 == 0) {
            setState(() {
              _statusMessage = 'Processing row $i/${table.rows.length - 1}...';
            });
            await Future.delayed(const Duration(milliseconds: 1));
          }
        } catch (e) {
          debugPrint('Error processing row $i: $e');
          _errorCount++;
        }
      }

      setState(() {
        _statusMessage = 'Uploading data to Firestore...';
      });

      await batch.commit();

      setState(() {
        _isLoading = false;
        _statusMessage = 'Import completed!\n'
            'Success: $_successCount\n'
            'Errors: $_errorCount';
        _hasError = _errorCount > 0;
      });
    } catch (e) {
      debugPrint('Import error: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Import failed: ${e.toString()}';
        _hasError = true;
      });
    }
  }

  String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import X-ray Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import X-ray Entries from Excel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Expected column order:\n'
              '1. Part of X-ray\n'
              '2. GMD No\n'
              '3. Patient Name\n'
              '4. Mobile Number\n'
              '5. Age\n'
              '6. Sex\n'
              '7. Doctor Name\n'
              '8. Payment Type\n'
              '9. Location Name\n'
              '10. Reference Fee\n'
              '11. Reference Person Name\n'
              '12. Paid/Due\n'
              '13. Date (optional)',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _importData,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Select Excel File and Import'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasError ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _hasError ? Colors.red[800] : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  final Timestamp timestamp;

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
    required this.timestamp,
  });

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
      'reference_fee': referenceFee.toDouble(),
      'referencePersonName': referencePersonName,
      'paid_or_due': paidOrDue,
      'timestamp': timestamp,
    };
  }
}
