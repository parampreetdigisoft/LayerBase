import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layerbase/authentication/forgotPassword/forgot_password.dart';
import 'package:layerbase/authentication/forgotPassword/forgot_password_view_model.dart';
import 'package:layerbase/authentication/login/login_screen.dart';
import 'package:layerbase/authentication/signUp/sign_up_screen.dart';
import 'package:layerbase/authentication/signUp/sign_up_view_model.dart';
import 'package:layerbase/imageEditor/components/gallery/gallery_screen_view_model.dart';
import 'package:layerbase/imageEditor/image_editor_screen.dart';
import 'package:layerbase/imageEditor/image_editor_view_model.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/splash_screen.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'authentication/login/login_view_model.dart';
import 'imageEditor/components/gallery_browse_file_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "secret.env");
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService().init();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox<dynamic>(AppKeys.imageLayerBox);
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
      GetPage(
        name: Routes.imageEditor,
        page: () => const ImageEditorScreen(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => ImageEditorViewModel()),
        ),
      ),

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
