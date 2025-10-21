import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zine_fitness/utilities/colors.dart';
import 'id_provider.dart';
import 'main_screens/home_page.dart';
import 'minor_screens/onboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/user_provider.dart';
import 'providers/filter_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    const firebaseOptions = FirebaseOptions(
      apiKey: "AIzaSyAvl1FIxjpxAjYqp7KIDLKEajc_S54ilEA",
      authDomain: "zine-tkd.firebaseapp.com",
      projectId: "zine-tkd",
      storageBucket: "zine-tkd.firebasestorage.app",
      messagingSenderId: "725704985171",
      appId: "1:725704985171:web:85b98e66c4fc66d36c54a6",
      measurementId: "G-WPLLPTS1LB",
    );

    await Firebase.initializeApp(options: firebaseOptions);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IdProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),   // new
        ChangeNotifierProvider(create: (_) => FilterProvider()), // new
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IdProvider>(
      builder: (context, idProvider, _) {
        String customerId = idProvider.getData;

        if (customerId.isEmpty) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: OnBoarding(),
          );
        }

        // Start listening to users as soon as app opens
        context.read<UserProvider>().startListening();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zine Fitness',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary ?? Colors.yellow.shade800,
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
