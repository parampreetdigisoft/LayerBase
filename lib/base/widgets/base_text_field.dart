import 'package:Layerbase/utils/constants/app_color.dart';
import 'package:Layerbase/utils/constants/app_constants.dart';
import 'package:Layerbase/utils/constants/app_strings.dart';
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
    this.fontSize = fontSize16,
  });

  final TextEditingController? textEditingController;
  final String? labelText;
  final String? hintText;
  final Icon? prefixIcon;
  final dynamic suffixIcon;
  final TextInputType? keyboardType;
  final bool isTextObscure;
  final Color hintColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      style: TextStyle(color: Colors.black, fontSize: fontSize),
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
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        focusColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.antiqueWhite, width: 1.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.required;
        }
        return null;
      },
      obscureText: isTextObscure,
      keyboardType: keyboardType,
    );
  }
}
