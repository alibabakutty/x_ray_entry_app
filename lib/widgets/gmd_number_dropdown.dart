import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GmdNumberDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<int>? validator;
  final Function(Map<String, dynamic>)?
      onGmdSelected; // new callback for related input fields

  const GmdNumberDropdown({
    super.key,
    required this.controller,
    this.label = 'GMD No.',
    this.hint = 'Select GMD No.',
    this.validator,
    this.onGmdSelected,
  });

  @override
  State<GmdNumberDropdown> createState() => _GmdNumberDropdownState();
}

class _GmdNumberDropdownState extends State<GmdNumberDropdown> {
  List<int> gmdNumbers = [];
  List<Map<String, dynamic>> gmdDataList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGmdNumbers();
  }

  Future<void> _fetchGmdNumbers() async {
    setState(() => isLoading = true);
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('gmd_data').get();

      setState(() {
        gmdDataList = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              dynamic gmdNo = data['gmd_no'];
              // Handle different number formats
              int number = 0;
              if (gmdNo is int) number = gmdNo;
              if (gmdNo is double) number = gmdNo.toInt();
              if (gmdNo is String) number = int.tryParse(gmdNo) ?? 0;

              return {
                ...data,
                'gmd_no': number,
              };
            })
            .where((item) => item['gmd_no'] != 0)
            .toList()
          ..sort((a, b) => (a['gmd_no'] as int)
              .compareTo(b['gmd_no'] as int)); // Sort numbers ascending
        gmdNumbers = gmdDataList.map((item) => item['gmd_no'] as int).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading GMD numbers: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleSelection(int? value) {
    if (value != null) {
      widget.controller.text = value.toString();
      // find the complete data for this GMD number
      final selectedData = gmdDataList.firstWhere(
        (item) => item['gmd_no'] == value,
        orElse: () => {},
      );

      if (widget.onGmdSelected != null && selectedData.isNotEmpty) {
        widget.onGmdSelected!(selectedData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : DropdownButtonFormField<int>(
            value: widget.controller.text.isEmpty
                ? null
                : int.tryParse(widget.controller.text),
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: widget.hint,
            ),
            items: gmdNumbers
                .map((gmd) => DropdownMenuItem<int>(
                      value: gmd,
                      child: Text(gmd.toString()),
                    ))
                .toList(),
            onChanged: _handleSelection,
            validator: (value) {
              if (widget.validator != null) {
                return widget.validator!(value);
              }
              if (value == null) {
                return 'Please select GMD Number';
              }
              return null;
            },
          );
  }
}
