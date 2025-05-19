import 'package:flutter/material.dart';

class GatewayPage extends StatefulWidget {
  const GatewayPage({super.key});

  @override
  State<GatewayPage> createState() => _GatewayPageState();
}

class _GatewayPageState extends State<GatewayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('X-Ray Management System'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master Section
            _buildSectionHeader('Master'),
            const SizedBox(height: 10),
            _buildNavigationButton(context, 'Part of X-Ray', '/cda',
                masterType: 'partOfXray'),
            _buildNavigationButton(context, 'GMD Master', '/cda',
                masterType: 'gmd'),
            _buildNavigationButton(context, 'Doctor Name', '/cda',
                masterType: 'doctorName'),
            _buildNavigationButton(context, 'Location', '/cda',
                masterType: 'location'),
            _buildNavigationButton(context, 'Reference Person', '/cda',
                masterType: 'referencePerson'),
            const SizedBox(height: 30),

            // Entry Section
            _buildSectionHeader('Entry'),
            const SizedBox(height: 10),
            _buildNavigationButton(context, 'X-Ray Entry', '/xrayEntryCreate'),
            const SizedBox(height: 30),

            // Reports Section
            _buildSectionHeader('Reports'),
            const SizedBox(height: 10),
            _buildNavigationButton(context, 'Entry Reports', '/entryReports'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, String label, String route,
      {String? masterType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            route,
            arguments: masterType, // Pass the masterType argument if needed
          );
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
