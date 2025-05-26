import 'package:flutter/material.dart';
import 'package:x_ray_entry_app/screens/admin_login_page.dart';
import 'package:x_ray_entry_app/screens/cda_page.dart';
import 'package:x_ray_entry_app/screens/display_master_page.dart';
import 'package:x_ray_entry_app/screens/doctor_name_master.dart';
import 'package:x_ray_entry_app/screens/executive_login_page.dart';
import 'package:x_ray_entry_app/screens/executive_name_master.dart';
import 'package:x_ray_entry_app/screens/gateway_page.dart';
import 'package:x_ray_entry_app/screens/gmd_master.dart';
import 'package:x_ray_entry_app/screens/import_data_page.dart';
import 'package:x_ray_entry_app/screens/location_master.dart';
import 'package:x_ray_entry_app/screens/part_of_xray_master.dart';
import 'package:x_ray_entry_app/screens/reference_person_master.dart';
import 'package:x_ray_entry_app/screens/report_master_page.dart';
import 'package:x_ray_entry_app/screens/update_master_page.dart';
import 'package:x_ray_entry_app/screens/xray_entry_sheet.dart';
import 'package:x_ray_entry_app/widget_tree.dart';

class AppRoutes {
  static const adminLogin = '/adminLogin';
  static const executiveLogin = '/executiveLogin';
  static const gateway = '/gateway';
  static const cda = '/cda';
  // Create Routes
  static const partOfXrayCreate = '/partOfXrayCreate';
  static const gmdCreate = '/gmdCreate';
  static const doctorNameCreate = '/doctorNameCreate';
  static const locationCreate = '/locationCreate';
  static const referencePersonCreate = '/referencePersonCreate';
  static const executiveNameCreate = '/executiveNameCreate';
  static const xrayEntryCreate = '/xrayEntryCreate';
  // fetch-master page
  static const displayMasterPage = '/displayMasterPage';
  static const updateMasterPage = '/updateMasterPage';
  // Update Routes
  static const partOfXrayUpdate = '/partOfXrayUpdate';
  static const gmdUpdate = '/gmdUpdate';
  static const doctorNameUpdate = '/doctorNameUpdate';
  static const locationUpdate = '/locationUpdate';
  static const referencePersonUpdate = '/referencePersonUpdate';
  static const executiveNameUpdate = '/executiveNameUpdate';
  static const reportMasterPage = '/reportMasterPage';
  // Import Routes
  static const importDataPage = '/importDataPage';

  static final routes = {
    adminLogin: (context) => const AdminLoginPage(),
    executiveLogin: (context) => const ExecutiveLoginPage(),
    gateway: (context) => const GatewayPage(),
    cda: (context) => const CdaPage(),
    partOfXrayCreate: (context) => const Partofxraymaster(),
    gmdCreate: (context) => const GmdMaster(),
    doctorNameCreate: (context) => const DoctorNameMaster(),
    locationCreate: (context) => const LocationMaster(),
    referencePersonCreate: (context) => const ReferencePersonMaster(),
    executiveNameCreate: (context) => const ExecutiveNameMaster(),
    xrayEntryCreate: (context) => const XrayEntrySheet(),
    // fetch-route
    displayMasterPage: (context) => const DisplayMasterPage(),
    updateMasterPage: (context) => const UpdateMasterPage(),
    // update-route
    partOfXrayUpdate: (context) => const Partofxraymaster(),
    gmdUpdate: (context) => const GmdMaster(),
    doctorNameUpdate: (context) => const DoctorNameMaster(),
    locationUpdate: (context) => const LocationMaster(),
    referencePersonUpdate: (context) => const ReferencePersonMaster(),
    executiveNameUpdate: (context) => const ExecutiveNameMaster(),
    reportMasterPage: (context) => const ReportMasterPage(),
    // import data page
    importDataPage: (context) => const ImportDataPage(),
  };

  // Add route generator for dynamic routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/partOfXrayNameDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => Partofxraymaster(
            partOfXrayName: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      case '/gmdDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => GmdMaster(
            gmdNo: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      case '/doctorNameDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => DoctorNameMaster(
            doctorName: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      case '/locationDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => LocationMaster(
            locationName: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      case '/referencePersonDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ReferencePersonMaster(
            referencePersonName: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      case '/executiveNameDisplay':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ExecutiveNameMaster(
            mobileNumber: args?['value'],
            isDisplayMode: args?['isDisplayMode'] ?? true,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const WidgetTree(),
        );
    }
  }
}
