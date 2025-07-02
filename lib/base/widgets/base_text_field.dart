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
  });

  final TextEditingController? textEditingController;
  final String? labelText;
  final String? hintText;
  final Icon? prefixIcon;
  final dynamic suffixIcon;
  final TextInputType? keyboardType;
  final bool isTextObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon ?? SizedBox(),
        suffixIcon: suffixIcon ?? SizedBox(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.antiqueWhite),
        ),focusColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
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
