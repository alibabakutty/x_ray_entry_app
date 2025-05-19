import 'package:flutter/material.dart';

class CdaPage extends StatelessWidget {
  const CdaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the master type from the arguments
    final masterType = ModalRoute.of(context)?.settings.arguments as String?;

    // Map master types to their respective routes
    final createRouteMap = <String, String>{
      'partOfXray': '/partOfXrayCreate',
      'gmd': '/gmdCreate',
      'doctorName': '/doctorNameCreate',
      'location': '/locationCreate',
      'referencePerson': '/referencePersonCreate',
    };

    // final updateRouteMap = <String, String>{
    //   'partOfXray': '/partOfXrayUpdate',
    //   'gmd': '/gmdUpdate',
    //   'doctorName': '/doctorNameUpdate',
    //   'location': '/locationUpdate',
    //   'referencePerson': '/referencePersonUpdate',
    // };
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(
            20.0), // Add padding to prevent edge-to-edge buttons
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Create Button
              _buildActionButton(
                context: context,
                icon: Icons.add,
                label: 'Create',
                route: masterType != null
                    ? createRouteMap[masterType] ?? '/'
                    : '/',
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 20),
              // Display Button
              _buildActionButton(
                context: context,
                icon: Icons.visibility,
                label: 'Display',
                route: '/displayMasterPage',
                color: Colors.blue.shade600,
                arguments: masterType,
              ),
              const SizedBox(height: 20),
              // Update Button
              _buildActionButton(
                context: context,
                icon: Icons.edit,
                label: 'Update',
                route: '/updateMasterPage',
                color: Colors.orange.shade600,
                arguments: masterType,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required Color color,
    Object? arguments,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50), // Set minimum height
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () =>
          Navigator.pushNamed(context, route, arguments: arguments),
    );
  }
}
