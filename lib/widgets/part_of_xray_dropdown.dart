import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PartOfXrayDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const PartOfXrayDropdown({
    Key? key,
    required this.controller,
    this.label = 'Part of X-RAY',
    this.hint = 'Select part of X-RAY',
    this.validator,
  }) : super(key: key);

  @override
  State<PartOfXrayDropdown> createState() => _PartOfXrayDropdownState();
}

class _PartOfXrayDropdownState extends State<PartOfXrayDropdown> {
  List<String> partOfXrayNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPartOfXrayNames();
  }

  Future<void> _fetchPartOfXrayNames() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('part_of_xray_data')
          .get();

      setState(() {
        partOfXrayNames = snapshot.docs
            .map((doc) => (doc.data()
                as Map<String, dynamic>)['part_of_xray_name'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading X-Ray parts: $e')),
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
            items: partOfXrayNames
                .map((part) => DropdownMenuItem(
                      value: part,
                      child: Text(part),
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
                    return 'Please select part of X-RAY';
                  }
                  return null;
                },
          );
  }
}
