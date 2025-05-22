import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2193b0),
              Color(0xFF6dd5ed),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Title
                Column(
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(20),
                    //   child: Image.asset(
                    //     'assets/logo.png',
                    //     width: 120,
                    //     height: 120,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    const Text(
                      'X-Ray ERP System',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Aptos',
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Login Options Card
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Admin Login Button
                      _buildLoginButton(
                        context,
                        text: 'Admin Login',
                        icon: Icons.admin_panel_settings,
                        onTap: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .loginAsAdmin();
                          Navigator.pushNamed(context, '/adminLogin');
                        },
                        isPrimary: true,
                      ),
                      const SizedBox(height: 25),

                      // Divider with "OR" text
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.5),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.5),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Guest Login Button
                      _buildLoginButton(
                        context,
                        text: 'Executive Login',
                        icon: Icons.person_outline,
                        onTap: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .loginAsExecutive();
                          Navigator.pushNamed(context, '/executiveLogin');
                        },
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: isPrimary
          ? Colors.blue.shade700.withOpacity(0.9)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Aptos',
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
