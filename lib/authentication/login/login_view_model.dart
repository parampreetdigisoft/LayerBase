import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart' show Routes;
import 'package:layerbase/utils/shared_prefs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/base/dialogs/base_dialog.dart';

class LoginViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final formKey = GlobalKey<FormState>();
  SharedPrefsService? sharedPreferences;
  ScrollController scrollController = ScrollController();

  @override
  onInit() {
    super.onInit();
    sharedPreferences = SharedPrefsService.instance;
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    scrollController.dispose();
  }

  Future<UserCredential?> signInWithGoogle() async {
    sharedPreferences!.clear();
    isLoading.value = true;

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );
      sharedPreferences!.setString(AppKeys.idToken, googleAuth.idToken ?? "");

      var data = await FirebaseAuth.instance.signInWithCredential(credential);
      return data;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      AppToast.show(
        title: AppStrings.error,
        e.message ?? AppStrings.googleSignInFailed,
        backgroundColor: Colors.red,
      );
      return null;
    } catch (e) {
      debugPrint(e.toString());
      AppToast.show(
        title: AppStrings.error,
        "${AppStrings.googleSignInFailed}:$e",
        backgroundColor: Colors.red,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    sharedPreferences!.clear();
    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
      sharedPreferences!.setString(AppKeys.email,userCredential.user!.email?? "");
      sharedPreferences!.setString(
        AppKeys.displayName,
        userCredential.user!.displayName??"",
      );
      sharedPreferences!.setString(
        AppKeys.idToken,
        userCredential.user!.refreshToken.toString(),
      );


      Navigator.pushReplacementNamed(Get.context!, Routes.homeScreen);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == AppKeys.userNotFound) {
        AppToast.show(
          title: AppStrings.validate,
          AppStrings.noUserFound,
          backgroundColor: Colors.red,
        );
      } else if (exception.code == AppKeys.wrongPassword) {
        AppToast.show(
          title: AppStrings.validate,
          AppStrings.wrongPasswordEntered,
          backgroundColor: Colors.red,
        );
      } else {
        AppToast.show(
          title: AppStrings.error,
          '${exception.message}',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, Routes.forgotPassword);
  }

  Future<UserCredential> signInWithGoogleWindow() async {
    final clientId = dotenv.env['windows_clientId'];
    final clientSecret = dotenv.env['windows_secretId'];

    final redirectUri = 'http://localhost:8080/';
    final scopes = ['openid', 'email', 'profile'];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
    });

    if (!await launchUrl(authUrl, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch browser for OAuth');
    }

    final request = await server.first;
    final query = request.uri.queryParameters;
    final code = query['code'];

    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html')
      ..write('<html lang="en"><h2>You can now close this window.</h2></html>');
    await request.response.close();
    await server.close(force: true);

    final tokenResponse = await exchangeCodeForToken(
      code!,
      redirectUri,
      clientId!,
      clientSecret!,
    );
    sharedPreferences!.setString(
      AppKeys.idToken,
      tokenResponse['id_token'] ?? "",
    );
    final credential = GoogleAuthProvider.credential(
      accessToken: tokenResponse['access_token'],
      idToken: tokenResponse['id_token'],
    );
    var data = await FirebaseAuth.instance.signInWithCredential(credential);
    return data;
  }

  Future<Map<String, dynamic>> exchangeCodeForToken(
    String code,
    String redirectUri,
    String clientId,
    String clientSecret,
  ) async {
    final tokenUrl = Uri.parse('https://oauth2.googleapis.com/token');

    final response = await http.post(
      tokenUrl,
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> signInWithEmailRest(String email, String password) async {
    sharedPreferences!.clear();
    isLoading.value = true;
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${dotenv.env['web_apiKey'] ?? ""}',
    );

    final Map<String, dynamic> map = {
      AppKeys.email: emailController.text,
      AppKeys.password: passwordController.text,
      "returnSecureToken": true,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map),
    );

    debugPrint("map::::$map");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      sharedPreferences!.setString(
        AppKeys.idToken,
        data['refreshToken'].toString(),
      );
      debugPrint("data::::::$data");
      sharedPreferences!.setString(AppKeys.email, data[AppKeys.email] ?? "");
      sharedPreferences!.setString(
        AppKeys.displayName,
        data[AppKeys.displayName] ?? "",
      );
      Navigator.pushReplacementNamed(Get.context!, Routes.homeScreen)
      ;
    } else {
      isLoading.value = false;
      AppToast.show(
        title: AppStrings.validate,
        AppStrings.noUserFound,
        backgroundColor: Colors.red,
      );
    }
  }

}
