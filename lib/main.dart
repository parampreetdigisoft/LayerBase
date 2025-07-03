import 'package:ecrumedia/authentication/forgotPassword/forgot_password.dart';
import 'package:ecrumedia/authentication/forgotPassword/forgot_password_view_model.dart';
import 'package:ecrumedia/authentication/login/login_screen.dart';
import 'package:ecrumedia/authentication/signUp/sign_up_screen.dart';
import 'package:ecrumedia/authentication/signUp/sign_up_view_model.dart';
import 'package:ecrumedia/components/image_editor_screen.dart';
import 'package:ecrumedia/firebase_options.dart';
import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'authentication/login/login_view_model.dart';
import 'utils/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "secret.env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
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
        GetPage(
          name: Routes.signUp,
          page: () => const SignUpScreen(),
          binding: BindingsBuilder(() => Get.lazyPut(() => SignUpViewModel())),
        ),
        GetPage(
          name: Routes.forgotPassword,
          page: () => const ForgotPassword(),
          binding: BindingsBuilder(
            () => Get.lazyPut(() => ForgotPasswordViewModel()),
          ),
        ),
        GetPage(name: Routes.editor, page: () => const ImageEditorScreen()),
      ],
    );
  }
}
