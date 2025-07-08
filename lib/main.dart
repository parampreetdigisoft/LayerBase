
import 'package:ecrumedia/authentication/forgotPassword/forgot_password.dart';
import 'package:ecrumedia/authentication/forgotPassword/forgot_password_view_model.dart';
import 'package:ecrumedia/authentication/login/login_screen.dart';
import 'package:ecrumedia/authentication/signUp/sign_up_screen.dart';
import 'package:ecrumedia/authentication/signUp/sign_up_view_model.dart';
import 'package:ecrumedia/imageEditor/gallery_screen_view_model.dart';
import 'package:ecrumedia/imageEditor/image_editor_screen.dart';
import 'package:ecrumedia/components/firebase_options.dart';
import 'package:ecrumedia/imageEditor/gallery_screen.dart';
import 'package:ecrumedia/utils/routes.dart';
import 'package:ecrumedia/splash_screen.dart';
import 'package:ecrumedia/utils/shared_prefs_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'authentication/login/login_view_model.dart';
import 'imageEditor/gallery_browse_file_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "secret.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService().init();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox<Uint8List>('imageBox');

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "1993919891452824",
      cookie: true,
      xfbml: true,
      version: "v23.0",
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      color: Colors.white,
      initialRoute: Routes.splash,
      getPages: routes(),
    );
  }

  routes() {
    return [
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

      GetPage(
        name: Routes.imageGallery,
        page: () => const GalleryBrowseFileScreen(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => GalleryScreenViewModel()),
        ),
      ),
    ];
  }
}
