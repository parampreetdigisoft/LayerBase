import 'package:ecrumedia/components/image_editor_screen.dart';
import 'package:ecrumedia/firebase_options.dart';
import 'package:ecrumedia/login/login_screen.dart';
import 'package:ecrumedia/login/login_view_model.dart';
import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      color: Colors.white,
      initialRoute: Routes.splash,
      getPages: [
        GetPage(name: Routes.splash, page: () => const SplashScreen()),
        GetPage(
          name: Routes.logIn,
          page: () => const LoginScreen(),
          binding: BindingsBuilder(() => Get.lazyPut(() => LoginViewModel())),
        ),
        GetPage(name: Routes.editor, page: () => const ImageEditorScreen()),
      ],
    );
  }
}
