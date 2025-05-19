import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';
import 'package:x_ray_entry_app/modals/doctor_name_data.dart';

class DoctorNameMaster extends StatefulWidget {
  const DoctorNameMaster(
      {super.key, this.doctorName, this.isDisplayMode = false});
  final String? doctorName;
  final bool isDisplayMode;

  @override
  State<DoctorNameMaster> createState() => _DoctorNameMasterState();
}

class _DoctorNameMasterState extends State<DoctorNameMaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController doctorNameController = TextEditingController();

  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;

  DoctorNameData? _doctorData;
  String? doctorNameFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          doctorNameFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
        });
        _fetchDoctorData(args);
      } else if (widget.doctorName != null) {
        setState(() {
          doctorNameFromArgs = widget.doctorName;
          _isEditing = !widget.isDisplayMode;
        });
        _fetchDoctorData(widget.doctorName!);
      }
    });
  }

  Future<void> _fetchDoctorData(String doctorName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await firebaseService.getDoctorDataByName(doctorName);
      if (data != null) {
        setState(() {
          _doctorData = data;
          doctorNameController.text = data.doctorName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No doctor data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading doctor data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final updatedDoctorData = DoctorNameData(
        // no: int.parse(noController.text.trim()),
        doctorName: doctorNameController.text.trim(),
        timestamp: _doctorData?.timestamp ?? Timestamp.now(),
      );

      final success = _isEditing
          ? await firebaseService.updateDoctorData(
              _doctorData!.doctorName, // Pass the original no
              updatedDoctorData)
          : await firebaseService.addDoctorNameData(updatedDoctorData);

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (_isEditing ? 'Doctor updated!' : 'Doctor added!')
                : 'Operation failed. Name might be already in use.'),
          ),
        );

        if (success && _isEditing) {
          Navigator.pop(context, true); // Return to previous screen
        } else if (success && !_isEditing) {
          doctorNameController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    doctorNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'Doctor Name Details: ${doctorNameFromArgs ?? ''}'
            : _isEditing
                ? 'Edit Doctor: ${doctorNameFromArgs ?? ''}'
                : 'Doctor Name Master'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child:
                  widget.isDisplayMode ? _buildDisplayView() : _buildEditView(),
            ),
    );
  }

  Widget _buildDisplayView() {
    if (_doctorData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Doctor Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doctor Name: ${_doctorData!.doctorName}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Last Updated: ${_doctorData!.timestamp.toDate()}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing && _doctorData != null) ...[
              const Text(
                'Edit Doctor Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ] else
              const Text(
                'Add New Doctor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 30),
            TextFormField(
              controller: doctorNameController,
              decoration: InputDecoration(
                labelText: 'Doctor Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'Enter doctor name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a doctor name';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Update' : 'Submit',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
