import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:x_ray_entry_app/authentication/auth_provider.dart';
import 'package:x_ray_entry_app/firebase_options.dart';
import 'package:x_ray_entry_app/widget_tree.dart';
import 'package:x_ray_entry_app/utils/routes.dart';

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
        theme: ThemeData(
          fontFamily: 'Aptos',
        ),
        debugShowCheckedModeBanner: false,
        title: 'X-Ray Entry App',
        home: WidgetTree(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
