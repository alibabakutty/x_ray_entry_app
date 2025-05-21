import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorNameDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const DoctorNameDropdown({
    super.key,
    required this.controller,
    this.label = 'Doctor Name',
    this.hint = 'Select Doctor Name',
    this.validator,
  });

  @override
  State<DoctorNameDropdown> createState() => _DoctorNameDropdownState();
}

class _DoctorNameDropdownState extends State<DoctorNameDropdown> {
  List<String> doctorNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorNames();
  }

  Future<void> _fetchDoctorNames() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('doctor_name_data').get();

      setState(() {
        doctorNames = snapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['doctor_name'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Doctor Names: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : DropdownButtonFormField<String>(
            value:
                widget.controller.text.isEmpty ? null : widget.controller.text,
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: widget.hint,
            ),
            items: doctorNames
                .map((doctor) => DropdownMenuItem(
                      value: doctor,
                      child: Text(doctor),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                widget.controller.text = value;
              }
            },
            validator: widget.validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select doctor name';
                  }
                  return null;
                },
          );
  }
}
