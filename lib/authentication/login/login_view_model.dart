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
import '../../utils/constants/app_constants.dart';

class LoginViewModel extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  SharedPrefsService? sharedPreferences;

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
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.email}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    if (!emailRegExp.hasMatch(value)) {
      return AppStrings.enterAValidEmail;
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.password}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    return null;
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      sharedPreferences!.setString(AppKeys.email, userCredential.user!.email ?? "");
      sharedPreferences!.setString(AppKeys.displayName, userCredential.user!.displayName ?? "");
      sharedPreferences!.setString(AppKeys.idToken, userCredential.user!.refreshToken.toString());

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
        AppToast.show(title: AppStrings.error, '${exception.message}', backgroundColor: Colors.red);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential> signInWithGoogleWindow() async {
    final clientId = dotenv.env[AppKeys.windowsClientId];
    final clientSecret = dotenv.env[AppKeys.windowsSecretId];
    final redirectUri = 'http://localhost:8080/';
    final scopes = [AppKeys.openid, AppKeys.email, AppKeys.profile];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      AppKeys.responseType: AppKeys.code,
      AppKeys.clientId: clientId,
      AppKeys.redirectUri: redirectUri,
      AppKeys.scope: scopes.join(' '),
      AppKeys.accessType: AppKeys.offline,
      AppKeys.prompt: AppKeys.consent,
    });

    if (!await launchUrl(authUrl, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch browser for OAuth');
    }

    final request = await server.first;
    final query = request.uri.queryParameters;
    final code = query[AppKeys.code];

    request.response
      ..statusCode = 200
      ..headers.set(AppKeys.contentType, 'text/html')
      ..write('<html lang="en"><h2>You can now close this window.</h2></html>');
    await request.response.close();
    await server.close(force: true);

    final tokenResponse = await exchangeCodeForToken(code!, redirectUri, clientId!, clientSecret!);
    sharedPreferences!.setString(AppKeys.idToken, tokenResponse[AppKeys.idToken] ?? "");
    final credential = GoogleAuthProvider.credential(
      accessToken: tokenResponse[AppKeys.accessToken],
      idToken: tokenResponse[AppKeys.idToken],
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
        AppKeys.code: code,
        AppKeys.clientId: clientId,
        AppKeys.clientSecret: clientSecret,
        AppKeys.redirectUri: redirectUri,
        AppKeys.grantType: AppKeys.authorizationCode,
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
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${dotenv.env[AppKeys.webApiKey] ?? ""}',
    );
    final Map<String, dynamic> map = {
      AppKeys.email: emailController.text,
      AppKeys.password: passwordController.text,
      AppKeys.returnSecureToken: true,
    };

    final response = await http.post(
      url,
      headers: {AppKeys.contentType: 'application/json'},
      body: jsonEncode(map),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint("data::::::$data");
      sharedPreferences!.setString(AppKeys.idToken, data[AppKeys.refreshToken].toString());
      sharedPreferences!.setString(AppKeys.email, data[AppKeys.email] ?? "");
      sharedPreferences!.setString(AppKeys.displayName, data[AppKeys.displayName] ?? "");
      Navigator.pushReplacementNamed(Get.context!, Routes.homeScreen);
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
