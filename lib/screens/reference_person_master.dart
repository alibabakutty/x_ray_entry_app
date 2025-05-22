import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/modals/reference_person_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class ReferencePersonMaster extends StatefulWidget {
  const ReferencePersonMaster(
      {super.key, this.referencePersonName, this.isDisplayMode = false});
  final String? referencePersonName;
  final bool isDisplayMode;

  @override
  State<ReferencePersonMaster> createState() => _ReferencePersonMasterState();
}

class _ReferencePersonMasterState extends State<ReferencePersonMaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController referencePersonNameController =
      TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;

  ReferencePersonData? _referencePersonData;
  String? referencePersonNameFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          referencePersonNameFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
        });
        _fetchReferencePersonData(args);
      } else if (widget.referencePersonName != null) {
        setState(() {
          referencePersonNameFromArgs = widget.referencePersonName;
          _isEditing = !widget.isDisplayMode;
        });
        _fetchReferencePersonData(widget.referencePersonName!);
      }
    });
  }

  Future<void> _fetchReferencePersonData(String referencePersonName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await firebaseService
          .getReferencePersonDataByName(referencePersonName);
      if (data != null) {
        setState(() {
          _referencePersonData = data;
          referencePersonNameController.text = data.referencePersonName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No Reference Person data found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Reference Person data.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final updatedReferencePersonData = ReferencePersonData(
        referencePersonName: referencePersonNameController.text.trim(),
        timestamp: _referencePersonData?.timestamp ?? Timestamp.now(),
      );

      final success = _isEditing
          ? await firebaseService.updateReferencePersonData(
              _referencePersonData!.referencePersonName,
              updatedReferencePersonData)
          : await firebaseService
              .addReferencePersonData(updatedReferencePersonData);

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success
                  ? (_isEditing
                      ? 'Reference Person Updated!'
                      : 'Reference Person Submitted!')
                  : 'Operation failed. Name might be already in use.')),
        );

        if (success && _isEditing) {
          Navigator.pop(context, true); // Return to previous screen
        } else if (success && !_isEditing) {
          referencePersonNameController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    referencePersonNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'Reference Person Details: ${referencePersonNameFromArgs ?? ''}'
            : _isEditing
                ? 'Edit Reference Person: ${referencePersonNameFromArgs ?? ''}'
                : 'Reference Person Master'),
        centerTitle: true,
        // backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: widget.isDisplayMode
                  ? _buildDisplayView()
                  : _buildEditView(authProvider),
            ),
    );
  }

  Widget _buildDisplayView() {
    if (_referencePersonData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Reference Person Details',
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Person Name: ${_referencePersonData!.referencePersonName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing && _referencePersonData != null) ...[
              const Text(
                'Edit Reference Person',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ] else
              const Text(
                'Add Reference Person',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            const SizedBox(height: 30),
            // Input Fields
            TextFormField(
              controller: referencePersonNameController,
              decoration: InputDecoration(
                labelText: 'Reference Person',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                hintText: 'Enter reference person name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter reference person name';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            // Submit Button
            if (!authProvider.isExecutive)
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
