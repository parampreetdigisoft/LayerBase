import 'package:get/get.dart';

import '../authentication/forgot_password/forgot_password.dart';
import '../authentication/forgot_password/forgot_password_view_model.dart';
import '../authentication/login/login_screen.dart';
import '../authentication/login/login_view_model.dart';
import '../authentication/sign_up/sign_up_screen.dart';
import '../authentication/sign_up/sign_up_view_model.dart';
import '../home_screen/home_controller.dart';
import '../home_screen/home_screen.dart';
import '../image_editor/image_editor_screen.dart';
import '../image_editor/image_editor_view_model.dart';
import '../splash_screen.dart';

class Routes {
  static const splash = '/';
  static const logIn = '/log_in';
  static const imageEditor = '/image_editor';
  static const signUp = '/sign_up';
  static const forgotPassword = '/forgot_password';
  static const imageGallery = '/image_gallery';
  static const homeScreen = '/home_screen';
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
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordViewModel());
      }),
    ),
    GetPage(
      name: Routes.imageEditor,
      page: () => ImageEditorScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ImageEditorViewModel())),
    ),
    GetPage(
      name: Routes.homeScreen,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
    ),
  ];
}
