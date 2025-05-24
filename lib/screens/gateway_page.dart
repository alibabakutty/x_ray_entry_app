import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';

class GatewayPage extends StatefulWidget {
  const GatewayPage({super.key});

  @override
  State<GatewayPage> createState() => _GatewayPageState();
}

class _GatewayPageState extends State<GatewayPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7A3C8E),
              Color(0xFF9C6FB3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7A3C8E),
                      Color(0xFF7A3C8E),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'X-Ray Management System',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (authProvider.username != null)
                            Text(
                              'Welcome, ${authProvider.username!}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'Logout',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Logout'),
                                  onPressed: () {
                                    final isAdmin = authProvider.isAdmin;
                                    authProvider.logout();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacementNamed(
                                      isAdmin
                                          ? '/adminLogin'
                                          : '/executiveLogin',
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
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
                      _buildNavigationButton(
                          context, 'Reference Person', '/cda',
                          masterType: 'referencePerson'),
                      if (authProvider.isAdmin)
                        _buildNavigationButton(
                            context, 'Executive Name', '/cda',
                            masterType: 'executive'),

                      const SizedBox(height: 30),

                      // Entry Section
                      _buildSectionHeader('Entry'),
                      const SizedBox(height: 10),
                      _buildNavigationButton(
                          context, 'X-Ray Entry', '/xrayEntryCreate'),
                      const SizedBox(height: 30),

                      // Import Section
                      _buildSectionHeader('Import'),
                      const SizedBox(height: 10),
                      _buildNavigationButton(
                          context, 'Import Data', '/importDataPage'),
                      const SizedBox(height: 30),

                      // Reports Section
                      _buildSectionHeader('Reports'),
                      const SizedBox(height: 10),
                      _buildNavigationButton(
                          context, 'Entry Reports', '/reportMasterPage'),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
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
          backgroundColor: Colors.blue.shade700.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            route,
            arguments: masterType,
          );
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
