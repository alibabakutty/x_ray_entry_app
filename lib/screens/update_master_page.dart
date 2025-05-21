import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:x_ray_entry_app/modals/gmd_data.dart';

class UpdateMasterPage extends StatefulWidget {
  const UpdateMasterPage({super.key});

  @override
  State<UpdateMasterPage> createState() => _UpdateMasterPageState();
}

class _UpdateMasterPageState extends State<UpdateMasterPage> {
  List<String> doctorNames = [];
  List<String> partOfXrayNames = [];
  List<String> locationNames = [];
  List<String> referencePersonNames = [];
  List<String> executivePersonMobileNumbers = [];
  List<int> gmdNumbers = []; // Changed to int
  List<GmdData> gmdDataList = [];
  bool isLoading = false;
  bool hasFetchedDoctors = false;
  bool hasFetchedPartOfXrayNames = false;
  bool hasFetchedLocationNames = false;
  bool hasFetchedReferencePersonNames = false;
  bool hasFetchedExecutivePersonMobileNumbers = false;
  bool hasFetchedGmdNumbers = false;
  String? masterType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          masterType = args;
        });
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      if (masterType == 'doctorName') {
        await _fetchDoctorNames();
      } else if (masterType == 'partOfXray') {
        await _fetchPartOfXrayNames();
      } else if (masterType == 'location') {
        await _fetchLocationNames();
      } else if (masterType == 'referencePerson') {
        await _fetchReferencePersonNames();
      } else if (masterType == 'gmd') {
        await _fetchGmdNumbers();
      } else if (masterType == 'executive') {
        await _fetchExecutivePersonMobileNumbers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDoctorNames() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('doctor_name_data').get();

      setState(() {
        doctorNames = snapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['doctor_name'] as String)
            .toList();
        hasFetchedDoctors = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctors: $e')),
      );
    }
  }

  Future<void> _fetchPartOfXrayNames() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('part_of_xray_data')
          .get();

      setState(() {
        partOfXrayNames = snapshot.docs
            .map((doc) => (doc.data()
                as Map<String, dynamic>)['part_of_xray_name'] as String)
            .toList();
        hasFetchedPartOfXrayNames = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching partOfXrayNames: $e')),
      );
    }
  }

  Future<void> _fetchLocationNames() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('location_data').get();

      setState(() {
        locationNames = snapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['location_name'] as String)
            .toList();
        hasFetchedLocationNames = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location names: $e')),
      );
    }
  }

  Future<void> _fetchReferencePersonNames() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reference_person_data')
          .get();

      setState(() {
        referencePersonNames = snapshot.docs
            .map((doc) => (doc.data()
                as Map<String, dynamic>)['reference_person_name'] as String)
            .toList();
        hasFetchedReferencePersonNames = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Reference Persons: $e')),
      );
    }
  }

  Future<void> _fetchExecutivePersonMobileNumbers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('executive_name_data')
          .get();

      setState(() {
        executivePersonMobileNumbers = snapshot.docs
            .map((doc) =>
                (doc.data() as Map<String, dynamic>)['mobile_number'] as String)
            .toList();
        hasFetchedExecutivePersonMobileNumbers = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Executive Persons: $e')),
      );
    }
  }

  Future<void> _fetchGmdNumbers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('gmd_data').get();

      setState(() {
        gmdDataList = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return GmdData(
                gmdNo: data['gmd_no'] is int
                    ? data['gmd_no']
                    : int.tryParse(data['gmd_no']?.toString() ?? '0') ?? 0,
                patientName: data['patient_name']?.toString() ?? '',
                mobileNumber: data['mobile_number']?.toString() ?? '',
                age: data['age'] is int ? data['age'] : 0,
                sex: data['sex']?.toString() ?? '',
                timestamp: data['timestamp'] ?? Timestamp.now(),
              );
            })
            .where((gmd) => gmd.gmdNo != 0)
            .toList();
        hasFetchedGmdNumbers = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching GMD data: $e')),
      );
    }
  }

  void _navigateToEditPage(dynamic value) {
    String route;

    if (masterType == 'doctorName') {
      route = '/doctorNameUpdate';
    } else if (masterType == 'partOfXray') {
      route = '/partOfXrayUpdate';
    } else if (masterType == 'location') {
      route = '/locationUpdate';
    } else if (masterType == 'referencePerson') {
      route = '/referencePersonUpdate';
    } else if (masterType == 'executive') {
      route = '/executiveNameUpdate';
    } else if (masterType == 'gmd') {
      route = '/gmdUpdate';
    } else {
      return;
    }

    Navigator.pushNamed(
      context,
      route,
      arguments: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          masterType == 'doctorName'
              ? 'Doctor Names'
              : masterType == 'partOfXray'
                  ? 'Part of X-Ray Names'
                  : masterType == 'referencePerson'
                      ? 'Reference Person Names'
                      : masterType == 'gmd'
                          ? 'GMD Numbers'
                          : masterType == 'executive'
                              ? 'Executive Person Names'
                              : 'Location Names',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (masterType == 'doctorName') {
      return _buildDoctorList();
    } else if (masterType == 'partOfXray') {
      return _buildPartOfXrayList();
    } else if (masterType == 'location') {
      return _buildLocationList();
    } else if (masterType == 'referencePerson') {
      return _buildReferencePersonList();
    } else if (masterType == 'gmd') {
      return _buildGmdNumbersList();
    } else if (masterType == 'executive') {
      return _buildExecutivePersonMobileNumbersList();
    } else {
      return const Center(child: Text('Invalid master type'));
    }
  }

  Widget _buildDoctorList() {
    if (!hasFetchedDoctors) {
      return const Center(child: Text('Press load to fetch doctors'));
    }
    return doctorNames.isEmpty
        ? const Center(child: Text('No doctors available'))
        : ListView.builder(
            itemCount: doctorNames.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(doctorNames[index]),
                  leading: const Icon(Icons.medical_services),
                  onTap: () => _navigateToEditPage(doctorNames[index]),
                ),
              );
            },
          );
  }

  Widget _buildPartOfXrayList() {
    if (!hasFetchedPartOfXrayNames) {
      return const Center(child: Text('Press load to fetch X-ray parts'));
    }
    return partOfXrayNames.isEmpty
        ? const Center(child: Text('No X-ray parts available'))
        : ListView.builder(
            itemCount: partOfXrayNames.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(partOfXrayNames[index]),
                  leading: const Icon(Icons.radar),
                  onTap: () => _navigateToEditPage(partOfXrayNames[index]),
                ),
              );
            },
          );
  }

  Widget _buildLocationList() {
    if (!hasFetchedLocationNames) {
      return const Center(child: Text('Press load to fetch locations'));
    }
    return locationNames.isEmpty
        ? const Center(child: Text('No locations available'))
        : ListView.builder(
            itemCount: locationNames.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(locationNames[index]),
                  leading: const Icon(Icons.location_on),
                  onTap: () => _navigateToEditPage(locationNames[index]),
                ),
              );
            },
          );
  }

  Widget _buildReferencePersonList() {
    if (!hasFetchedReferencePersonNames) {
      return const Center(child: Text('Press load to fetch reference persons'));
    }
    return referencePersonNames.isEmpty
        ? const Center(child: Text('No Reference Persons Available'))
        : ListView.builder(
            itemCount: referencePersonNames.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(referencePersonNames[index]),
                  leading: const Icon(Icons.person),
                  onTap: () => _navigateToEditPage(referencePersonNames[index]),
                ),
              );
            },
          );
  }

  Widget _buildExecutivePersonMobileNumbersList() {
    if (!hasFetchedExecutivePersonMobileNumbers) {
      return const Center(
          child: Text('Press load to fetch executive person mobile numbers'));
    }
    return executivePersonMobileNumbers.isEmpty
        ? const Center(
            child:
                Text('No Executive persons available with this mobile number'))
        : ListView.builder(
            itemCount: executivePersonMobileNumbers.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(executivePersonMobileNumbers[index]),
                  leading: const Icon(Icons.person),
                  onTap: () =>
                      _navigateToEditPage(executivePersonMobileNumbers[index]),
                ),
              );
            },
          );
  }

  Widget _buildGmdNumbersList() {
    if (!hasFetchedGmdNumbers) {
      return const Center(child: Text('Press load to fetch GMD numbers'));
    }
    return gmdDataList.isEmpty
        ? const Center(child: Text('No GMD Numbers Available'))
        : ListView.builder(
            itemCount: gmdDataList.length,
            itemBuilder: (context, index) {
              final gmd = gmdDataList[index];
              return Card(
                child: ListTile(
                  title: Text('GMD No.: ${gmd.gmdNo}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Name: ${gmd.patientName}'),
                      Text('Mobile No.: ${gmd.mobileNumber}')
                    ],
                  ),
                  leading: const Icon(Icons.numbers),
                  onTap: () => _navigateToEditPage(gmd.gmdNo),
                ),
              );
            },
          );
  }
}
