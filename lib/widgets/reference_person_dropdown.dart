import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReferencePersonDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const ReferencePersonDropdown({
    super.key,
    required this.controller,
    this.label = 'Reference Person',
    this.hint = 'Select Reference Person',
    this.validator,
  });

  @override
  State<ReferencePersonDropdown> createState() =>
      _ReferencePersonDropdownState();
}

class _ReferencePersonDropdownState extends State<ReferencePersonDropdown> {
  List<String> referencePersonNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReferencePersonNames();
  }

  Future<void> _fetchReferencePersonNames() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reference_person_data')
          .get();

      setState(() {
        referencePersonNames = snapshot.docs
            .map((doc) => (doc.data()
                as Map<String, dynamic>)['reference_person_name'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Reference Person Names: $e')),
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
            items: referencePersonNames
                .map((reference) => DropdownMenuItem(
                      value: reference,
                      child: Text(reference),
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
                    return 'Please select reference person name';
                  }
                  return null;
                },
          );
  }
}
