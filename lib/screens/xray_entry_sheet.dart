import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:x_ray_entry_app/modals/xray_entry_sheet_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';
import 'package:x_ray_entry_app/widgets/doctor_name_dropdown.dart';
import 'package:x_ray_entry_app/widgets/gmd_number_dropdown.dart';
import 'package:x_ray_entry_app/utils/input_field.dart';
import 'package:x_ray_entry_app/widgets/location_dropdown.dart';
import 'package:x_ray_entry_app/widgets/part_of_xray_dropdown.dart';
import 'package:x_ray_entry_app/widgets/reference_person_dropdown.dart';

class XrayEntrySheet extends StatefulWidget {
  const XrayEntrySheet({super.key});

  @override
  State<XrayEntrySheet> createState() => _XrayEntrySheetState();
}

class _XrayEntrySheetState extends State<XrayEntrySheet> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController partOfXrayController = TextEditingController();
  final TextEditingController gmdNoController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController referenceFeeController = TextEditingController();
  final TextEditingController referencePersonNameController =
      TextEditingController();
  final TextEditingController paidOrDueController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    partOfXrayController.dispose();
    gmdNoController.dispose();
    patientNameController.dispose();
    mobileNumberController.dispose();
    ageController.dispose();
    sexController.dispose();
    doctorNameController.dispose();
    paymentTypeController.dispose();
    locationNameController.dispose();
    referenceFeeController.dispose();
    referencePersonNameController.dispose();
    paidOrDueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    print('Submit button pressed');
    if (_formKey.currentState!.validate()) {
      print('Form is valid!, submitting...');
      setState(() {
        _isSubmitting = true;
      });

      final xrayEntrySheetData = XrayEntrySheetData(
        partOfXray: partOfXrayController.text.trim(),
        gmdNo: int.tryParse(gmdNoController.text.trim()) ?? 0,
        patientName: patientNameController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        age: int.tryParse(ageController.text.trim()) ?? 0,
        sex: sexController.text.trim(),
        doctorName: doctorNameController.text.trim(),
        paymentType: paymentTypeController.text.trim(),
        locationName: locationNameController.text.trim(),
        referenceFee: Decimal.tryParse(referenceFeeController.text.trim()) ??
            Decimal.zero, // parse as decimal
        referencePersonName: referencePersonNameController.text.trim(),
        paidOrDue: paidOrDueController.text.trim(),
        timestamp: Timestamp.now(),
      );

      final success =
          await firebaseService.addXrayEntrySheetData(xrayEntrySheetData);

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        print('Data submitted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('X-Ray Sheet added successfully!')),
        );
        partOfXrayController.clear();
        gmdNoController.clear();
        patientNameController.clear();
        mobileNumberController.clear();
        ageController.clear();
        sexController.clear();
        doctorNameController.clear();
        paymentTypeController.clear();
        locationNameController.clear();
        referenceFeeController.clear();
        referencePersonNameController.clear();
        paidOrDueController.clear();
      } else {
        print('Failed to submit data.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add X-Ray Sheet!')),
        );
      }
    } else {
      print('Form is invalid!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X-Ray Entry Sheet Master'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Fields Section
                const SizedBox(
                  height: 10,
                ),
                PartOfXrayDropdown(
                  controller: partOfXrayController,
                  label: 'Select X-Ray Part',
                  hint: 'Choose from list',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required field';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                GmdNumberDropdown(
                  controller: gmdNoController,
                  label: 'GMD No.',
                  hint: 'Choose GMD No.',
                  validator: (value) {
                    if (value == null) {
                      return 'Invalid GMD No.!';
                    }
                    return null;
                  },
                  onGmdSelected: (patientData) {
                    setState(() {
                      patientNameController.text =
                          patientData['patient_name'] ?? '';
                      mobileNumberController.text =
                          patientData['mobile_number'] ?? '';
                      ageController.text = patientData['age']?.toString() ?? '';
                      sexController.text = patientData['sex'] ?? '';
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                InputField(
                  label: 'PATIENT NAME',
                  controller: patientNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'MOBILE NUMBER',
                  controller: mobileNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'AGE',
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid age';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'SEX',
                  controller: sexController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter sex';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                DoctorNameDropdown(
                  controller: doctorNameController,
                  label: 'Select doctor name',
                  hint: 'choose from list',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select doctor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  value: paymentTypeController.text.isEmpty
                      ? null
                      : paymentTypeController.text,
                  decoration: InputDecoration(
                    labelText: 'PAYMENT TYPE',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ['Cash', 'Gpay', 'Others']
                      .map((payment) => DropdownMenuItem(
                            value: payment,
                            child: Text(payment),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      paymentTypeController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select payment type';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                LocationDropdown(
                  controller: locationNameController,
                  label: 'select location',
                  hint: 'choose from list',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select location';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                InputField(
                  label: 'REFERENCE FEE',
                  controller: referenceFeeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixText: '₹ ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reference fee';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ReferencePersonDropdown(
                  controller: referencePersonNameController,
                  label: 'Reference Person',
                  hint: 'choose from list',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select reference person';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                DropdownButtonFormField<String>(
                  value: paidOrDueController.text.isEmpty
                      ? null
                      : paidOrDueController.text,
                  decoration: InputDecoration(
                    labelText: 'Paid/Due',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: ['Paid', 'Due']
                      .map((pay) => DropdownMenuItem(
                            value: pay,
                            child: Text(pay),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      paidOrDueController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select paid/due';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),
                // Add this above your submit button
                Text(
                  'Entry Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                // beautiful submit button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 24),
                    label: _isSubmitting
                        ? const Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
