import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/modals/gmd_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class GmdMaster extends StatefulWidget {
  const GmdMaster({super.key, this.gmdNo, this.isDisplayMode = false});
  final int? gmdNo;
  final bool isDisplayMode;

  @override
  State<GmdMaster> createState() => _GmdMasterState();
}

class _GmdMasterState extends State<GmdMaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController gmdNoController = TextEditingController();
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;

  GmdData? _gmdData;
  int? gmdNoFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        setState(() {
          gmdNoFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
        });
        _fetchGmdData(args);
      } else if (widget.gmdNo != null) {
        setState(() {
          gmdNoFromArgs = widget.gmdNo;
          _isEditing = !widget.isDisplayMode;
        });
        _fetchGmdData(widget.gmdNo!);
      }
    });
  }

  Future<void> _fetchGmdData(int gmdNo) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await firebaseService.getGmdDataByNumber(gmdNo);
      if (data != null) {
        setState(() {
          _gmdData = data;
          gmdNoController.text = data.gmdNo.toString();
          patientNameController.text = data.patientName;
          mobileNumberController.text = data.mobileNumber;
          ageController.text = data.age.toString();
          sexController.text = data.sex;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No data found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
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

      final updatedGmdData = GmdData(
        gmdNo: int.parse(gmdNoController.text.trim()),
        patientName: patientNameController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        age: int.parse(ageController.text.trim()),
        sex: sexController.text.trim(),
        timestamp: _gmdData?.timestamp ?? Timestamp.now(),
      );

      final success = _isEditing
          ? await firebaseService.updateGmdData(_gmdData!.gmdNo, updatedGmdData)
          : await firebaseService.addGmdData(updatedGmdData);

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(success
                  ? (_isEditing ? 'GMD Master updated!' : 'GMD Master added!')
                  : 'Operation failed. ID might be already in use.')),
        );

        if (success && _isEditing) {
          Navigator.pop(context, true); // Return to previous screen
        } else if (success && !_isEditing) {
          gmdNoController.clear();
          patientNameController.clear();
          mobileNumberController.clear();
          ageController.clear();
          sexController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    gmdNoController.dispose();
    patientNameController.dispose();
    mobileNumberController.dispose();
    ageController.dispose();
    sexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'GMD Details: ${gmdNoFromArgs ?? ''}'
            : _isEditing
                ? 'Edit GMD Master: ${gmdNoFromArgs ?? ''}'
                : 'GMD Master'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: widget.isDisplayMode
                  ? _buildDisplayView()
                  : _buildEditView(authProvider),
            ),
    );
  }

  Widget _buildDisplayView() {
    if (_gmdData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current GMD Details',
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
                    'GMD No: ${_gmdData!.gmdNo}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient Name: ${_gmdData!.patientName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mobile Number: ${_gmdData!.mobileNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age: ${_gmdData!.age}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sex: ${_gmdData!.sex}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_gmdData!.timestamp.toDate()}',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing && _gmdData != null) ...[
            const Text(
              'Edit GMD Master',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ] else
            const Text(
              'Add New GMD Master Details',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          const SizedBox(height: 30),
          // input fields
          TextFormField(
            controller: gmdNoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'GMD No.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              hintText: 'Enter GMD No. (e.g., 1)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid number';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: patientNameController,
            decoration: InputDecoration(
              labelText: 'Patient Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              hintText: 'Enter Patient Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter patient name';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: mobileNumberController,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              hintText: 'Enter Mobile Number',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              hintText: 'Enter Age',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter age';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: sexController.text.isEmpty ? null : sexController.text,
            decoration: InputDecoration(
              labelText: 'Sex',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: ['Male', 'Female', 'Other']
                .map((sex) => DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                sexController.text = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select sex';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          // Submit
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          const SizedBox(height: 20), // Extra space at bottom
        ],
      ),
    );
  }
}
