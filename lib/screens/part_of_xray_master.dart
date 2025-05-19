import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/modals/part_of_xray_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class Partofxraymaster extends StatefulWidget {
  const Partofxraymaster(
      {super.key, this.partOfXrayName, this.isDisplayMode = false});
  final String? partOfXrayName;
  final bool isDisplayMode;

  @override
  State<Partofxraymaster> createState() => _PartofxraymasterState();
}

class _PartofxraymasterState extends State<Partofxraymaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController partOfXrayNameController =
      TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;

  PartOfXrayData? _xrayNameData;
  String? partOfXrayNameFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          partOfXrayNameFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
        });
        _fetchParrtOfXrayData(args);
      } else if (widget.partOfXrayName != null) {
        setState(() {
          partOfXrayNameFromArgs = widget.partOfXrayName;
          _isEditing = !widget.isDisplayMode;
        });
        _fetchParrtOfXrayData(widget.partOfXrayName!);
      }
    });
  }

  Future<void> _fetchParrtOfXrayData(String partOfXrayName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await firebaseService.getPartOfXrayName(partOfXrayName);
      if (data != null) {
        setState(() {
          _xrayNameData = data;
          partOfXrayNameController.text = data.partOfXrayName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No Part of X-Ray data found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Part of X-Ray data: $e')),
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

      final updatedPartofXrayData = PartOfXrayData(
        partOfXrayName: partOfXrayNameController.text.trim(),
        timestamp: _xrayNameData?.timestamp ?? Timestamp.now(),
      );

      final success = _isEditing
          ? await firebaseService.updatePartOfXrayData(
              _xrayNameData!.partOfXrayName, updatedPartofXrayData)
          : await firebaseService.addPartOfXrayData(updatedPartofXrayData);

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (_isEditing
                    ? 'Part of X-Ray updated!'
                    : 'Part of X-Ray added!')
                : 'Operation failed. Name might be already in use.'),
          ),
        );

        if (success && _isEditing) {
          Navigator.pop(context, true); // Return to previous screen
        } else if (success && !_isEditing) {
          partOfXrayNameController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    partOfXrayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'Part of X-Ray Name Details: ${partOfXrayNameFromArgs ?? ''}'
            : _isEditing
                ? 'Edit Part of X-Ray: ${partOfXrayNameFromArgs ?? ''}'
                : 'Part of X-Ray Master'),
        centerTitle: true,
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
    if (_xrayNameData == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Part of X-Ray Details',
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
                    'Part of X-Ray Name: ${_xrayNameData!.partOfXrayName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_xrayNameData!.timestamp.toDate()}',
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
            if (_isEditing && _xrayNameData != null)
              const Text(
                'Edit Part of X-Ray Name',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              )
            else
              const Text(
                'Add New Part of X-Ray Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 30),
            TextFormField(
              controller: partOfXrayNameController,
              decoration: InputDecoration(
                labelText: 'Part of X-Ray',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Enter part of X-Ray (e.g., Chest, Abdomen)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a part of x-ray';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            if (!authProvider.isGuest)
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
