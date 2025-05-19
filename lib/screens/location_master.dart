import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:x_ray_entry_app/modals/location_data.dart';
import 'package:x_ray_entry_app/services/firebase_service.dart';

class LocationMaster extends StatefulWidget {
  const LocationMaster(
      {super.key, this.locationName, this.isDisplayMode = false});
  final String? locationName;
  final bool isDisplayMode;

  @override
  State<LocationMaster> createState() => _LocationMasterState();
}

class _LocationMasterState extends State<LocationMaster> {
  final FirebaseService firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController noController = TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isLoading = false;

  LocationData? _locationData;
  String? locationNameFromArgs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          locationNameFromArgs = args;
          _isEditing =
              !widget.isDisplayMode; // only editing if not in display mode
        });
        _fetchLocationData(args);
      } else if (widget.locationName != null) {
        setState(() {
          locationNameFromArgs = widget.locationName;
          _isEditing = !widget.isDisplayMode;
        });
        _fetchLocationData(widget.locationName!);
      }
    });
  }

  Future<void> _fetchLocationData(String locationName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await firebaseService.getLocationDataByName(locationName);
      if (data != null) {
        setState(() {
          _locationData = data;
          noController.text = data.no.toString();
          locationNameController.text = data.locationName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data Location Data: $e')),
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

      final updatedLocationData = LocationData(
        no: int.parse(noController.text.trim()),
        locationName: locationNameController.text.trim(),
        timestamp: _locationData?.timestamp ?? Timestamp.now(),
      );

      final success = _isEditing
          ? await firebaseService.updateLocationData(
              _locationData!.no, updatedLocationData)
          : await firebaseService.addLocationData(updatedLocationData);

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? (_isEditing
                    ? 'Location Master Updated!'
                    : 'Location Name Added!')
                : 'Operation failed. ID might be already in use.'),
          ),
        );

        if (success && _isEditing) {
          Navigator.pop(context, true); // Return to previous screen
        } else if (success && !_isEditing) {
          noController.clear();
          locationNameController.clear();
        }
      }
    }
  }

  @override
  void dispose() {
    noController.dispose();
    locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDisplayMode
            ? 'Location Details: ${locationNameFromArgs ?? ''}'
            : _isEditing
                ? 'Edit Location: ${locationNameFromArgs ?? ''}'
                : 'Location Master'),
        centerTitle: true,
        // backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  widget.isDisplayMode ? _buildDisplayView() : _buildEditView(),
            ),
    );
  }

  Widget _buildDisplayView() {
    if (_locationData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Location Details',
            style: TextStyle(
              fontSize: 18,
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
                    'Location Name: ${_locationData!.locationName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_locationData!.timestamp.toDate()}',
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

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing && _locationData != null) ...[
              const Text(
                'Edit Location Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ] else
              const Text(
                'Add New Location Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 30),
            TextFormField(
              controller: noController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Location Number',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter Location ID or No. (e.g., 001)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location number';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Input Fields
            TextFormField(
              controller: locationNameController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                hintText: 'Enter location',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location name';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            // submit button
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
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
