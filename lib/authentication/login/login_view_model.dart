import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart' show Routes;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants/app_constants.dart';
import 'package:http/http.dart' as http;

class LoginViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final formKey = GlobalKey<FormState>();
  SharedPreferences? sharedPreferences;
  ScrollController scrollController = ScrollController();
  final List<String> _scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    sharedPreferences = await SharedPreferences.getInstance();
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
      print(e.message);

      BaseSnackBar.show(
        title: AppStrings.error,
        message: e.message ?? AppStrings.googleSignInFailed,
      );
      return null;
    } catch (e) {
      debugPrint(e.toString());
      BaseSnackBar.show(
        title: AppStrings.error,
        message: "${AppStrings.googleSignInFailed}: $e",
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
      sharedPreferences!.setString(
        AppKeys.idToken,
        userCredential.user!.refreshToken.toString(),
      );

      Navigator.pushReplacementNamed(Get.context!, Routes.imageGallery);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == AppKeys.userNotFound) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.noUserFound,
        );
      } else if (exception.code == AppKeys.wrongPassword) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.wrongPasswordEntered,
        );
      } else {
        BaseSnackBar.show(
          title: AppStrings.error,
          message: '${exception.message}',
        );

        BaseSnackBar.show(
          title: AppStrings.validate,
          message: '${exception.message}',
        );
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> logInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        final data = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        sharedPreferences!.setString(
          AppKeys.idToken,
          result.accessToken!.tokenString.toString(),
        );

        return data;
      } else {
        debugPrint(result.message);
        return null;
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }

  forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, Routes.forgotPassword);
  }

  Future<UserCredential> signInWithGoogleWindow() async {
    final clientId =
    dotenv.env['windows_clientId']; // Replace with your Client ID
    final clientSecret =
    dotenv.env['windows_secretId']; // Replace with your Client Secret


    final redirectUri = 'http://localhost:8080/';
    final scopes = ['openid', 'email', 'profile'];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

    // 2. Build the authorization URL
    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
      'access_type': 'offline', // to get refresh token
      'prompt': 'consent', // force consent to get refresh token
    });

    // 3. Launch the URL in the browser
    if (!await launchUrl(authUrl, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch browser for OAuth');
    }

    // 4. Wait for the redirect with the code
    final request = await server.first;
    final query = request.uri.queryParameters;
    final code = query['code'];

    // Respond to the browser so user knows they can close it
    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html')
      ..write('<html><h2>You can now close this window.</h2></html>');
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

  Future<Map<String, dynamic>> exchangeCodeForToken(String code,
      String redirectUri,
      String clientId,
      String clientSecret,) async {
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
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    return jsonDecode(response.body);
  }


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    scrollController.dispose();
  }
}
