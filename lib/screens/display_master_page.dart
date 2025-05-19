import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayMasterPage extends StatefulWidget {
  const DisplayMasterPage({super.key});

  @override
  State<DisplayMasterPage> createState() => _DisplayMasterPageState();
}

class _DisplayMasterPageState extends State<DisplayMasterPage> {
  List<String> doctorNames = [];
  List<String> partOfXrayNames = [];
  List<String> locationNames = [];
  List<String> referencePersonNames = [];
  List<int> gmdNumbers = [];
  bool isLoading = false;
  bool hasFetchedDoctors = false;
  bool hasFetchedPartOfXrayNames = false;
  bool hasFetchedLocationNames = false;
  bool hasFetchedReferencePersonNames = false;
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
    setState(() {
      isLoading = true;
    });

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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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

  Future<void> _fetchGmdNumbers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('gmd_data').get();

      setState(() {
        gmdNumbers = snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final rawValue = data['gmd_no'];

              if (rawValue is int) return rawValue;
              if (rawValue is String) return int.tryParse(rawValue) ?? 0;
              return 0;
            })
            .where((value) => value != 0)
            .toList();
        hasFetchedGmdNumbers = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching GMD numbers: $e')),
      );
    }
  }

  void _navigateToEditPage(dynamic value) {
    String route;

    if (masterType == 'doctorName') {
      route = '/doctorNameDisplay';
    } else if (masterType == 'partOfXray') {
      route = '/partOfXrayNameDisplay';
    } else if (masterType == 'location') {
      route = '/locationDisplay';
    } else if (masterType == 'referencePerson') {
      route = '/referencePersonDisplay';
    } else if (masterType == 'gmd') {
      route = '/gmdDisplay';
    } else {
      return;
    }

    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'value': value,
        'isDisplayMode': true,
      },
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
                          : 'Location Names',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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

  Widget _buildGmdNumbersList() {
    if (!hasFetchedGmdNumbers) {
      return const Center(child: Text('Press load to fetch GMD numbers'));
    }
    return gmdNumbers.isEmpty
        ? const Center(child: Text('No GMD Numbers Available'))
        : ListView.builder(
            itemCount: gmdNumbers.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(gmdNumbers[index].toString()),
                  leading: const Icon(Icons.numbers),
                  onTap: () => _navigateToEditPage(gmdNumbers[index]),
                ),
              );
            },
          );
  }
}
