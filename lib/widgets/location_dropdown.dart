import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const LocationDropdown({
    super.key,
    required this.controller,
    this.label = 'Location',
    this.hint = 'Select Location',
    this.validator,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  List<String> locationNames = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationNames();
  }

  Future<void> _fetchLocationNames() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('location_data').get();

      setState(() {
        locationNames = snapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['location_name'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading location names: $e')),
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
            items: locationNames
                .map((location) => DropdownMenuItem(
                      value: location,
                      child: Text(location),
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
                    return 'Please select location';
                  }
                  return null;
                },
          );
  }
}
