import 'package:ecrumedia/utils/app_color.dart';
import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    super.key,
    this.textEditingController,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.isTextObscure = false,
    this.hintColor = AppColors.lightBlue,
  });

  final TextEditingController? textEditingController;
  final String? labelText;
  final String? hintText;
  final Icon? prefixIcon;
  final dynamic suffixIcon;
  final TextInputType? keyboardType;
  final bool isTextObscure;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: prefixIcon,
        prefixIconColor: AppColors.darkBlue,
        suffixIcon: suffixIcon ?? SizedBox(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        focusColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.antiqueWhite, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: isTextObscure,
      keyboardType: keyboardType,
    );
  }
}
