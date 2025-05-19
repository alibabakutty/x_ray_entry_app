import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:x_ray_entry_app/modals/xray_entry_sheet_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';
import 'package:x_ray_entry_app/widgets/input_field.dart';

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
                InputField(
                  label: 'Part of X-RAY',
                  controller: partOfXrayController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter part of x-ray';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'GMD NUMBER',
                  controller: gmdNoController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter GMD Number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter valid GMD Number';
                    }
                    return null;
                  },
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
                InputField(
                  label: 'DOCTOR NAME',
                  controller: doctorNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'PAYMENT TYPE',
                  controller: paymentTypeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter payment type';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'LOCATION',
                  controller: locationNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location name';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'REFERENCE FEE',
                  controller: referenceFeeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reference fee';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'REFERENCE PERSON',
                  controller: referencePersonNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reference person name';
                    }
                    return null;
                  },
                ),
                InputField(
                  label: 'PAID/DUE',
                  controller: paidOrDueController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter paid/due status';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),
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
