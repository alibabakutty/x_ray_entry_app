import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/firebase_options.dart';
import 'package:x_ray_entry_app/screens/cda_page.dart';
import 'package:x_ray_entry_app/screens/display_master_page.dart';
import 'package:x_ray_entry_app/screens/gateway_page.dart';
import 'package:x_ray_entry_app/screens/login_page.dart';
import 'package:x_ray_entry_app/screens/update_master_page.dart';
import 'package:x_ray_entry_app/screens/doctor_name_master.dart';
import 'package:x_ray_entry_app/screens/gmd_master.dart';
import 'package:x_ray_entry_app/screens/location_master.dart';
import 'package:x_ray_entry_app/screens/part_of_xray_master.dart';
import 'package:x_ray_entry_app/screens/reference_person_master.dart';
import 'package:x_ray_entry_app/screens/xray_entry_sheet.dart';
import 'package:x_ray_entry_app/widget_tree.dart';

void main() async {
  // Ensure that plugin services are initialized so that Firebase can use them
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(XRayEntryApp());
}

class XRayEntryApp extends StatelessWidget {
  const XRayEntryApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'X-Ray Entry App',
        home: WidgetTree(),
        routes: {
          '/adminLogin': (context) => const LoginPage(),
          '/gateway': (context) => const GatewayPage(),
          '/cda': (context) => const CdaPage(),
          // Create Routes
          '/partOfXrayCreate': (context) => const Partofxraymaster(),
          '/gmdCreate': (context) => const GmdMaster(),
          '/doctorNameCreate': (context) => const DoctorNameMaster(),
          '/locationCreate': (context) => const LocationMaster(),
          '/referencePersonCreate': (context) => const ReferencePersonMaster(),
          '/xrayEntryCreate': (context) => const XrayEntrySheet(),
          // Display Routes
          '/displayMasterPage': (context) => const DisplayMasterPage(),
          '/updateMasterPage': (context) => const UpdateMasterPage(),

          '/partOfXrayNameDisplay': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return Partofxraymaster(
              partOfXrayName: args?['value'],
              isDisplayMode: args?['isDisplayMode'] ?? true,
            );
          },
          '/gmdDisplay': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return GmdMaster(
              gmdNo: args?['value'],
              isDisplayMode: args?['isDisplayMode'] ?? true,
            );
          },
          '/doctorNameDisplay': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return DoctorNameMaster(
              doctorName: args?['value'],
              isDisplayMode: args?['isDisplayMode'] ?? true,
            );
          },
          '/locationDisplay': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return LocationMaster(
              locationName: args?['value'],
              isDisplayMode: args?['isDisplayMode'] ?? true,
            );
          },
          '/referencePersonDisplay': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            return ReferencePersonMaster(
              referencePersonName: args?['value'],
              isDisplayMode: args?['isDisplayMode'] ?? true,
            );
          },
          '/xrayEntryDisplay': (context) => const XrayEntrySheet(),
          // Update Routes
          '/partOfXrayUpdate': (context) => const Partofxraymaster(),
          '/gmdUpdate': (context) => const GmdMaster(),
          '/doctorNameUpdate': (context) => const DoctorNameMaster(),
          '/locationUpdate': (context) => const LocationMaster(),
          '/referencePersonUpdate': (context) => const ReferencePersonMaster(),
          '/xrayEntryUpdate': (context) => const XrayEntrySheet(),
        },
      ),
    );
  }
}
