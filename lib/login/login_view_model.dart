import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginViewModel extends GetxController{
  RxBool isLoading= false.obs;
  RxBool isPasswordObscure= true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

}