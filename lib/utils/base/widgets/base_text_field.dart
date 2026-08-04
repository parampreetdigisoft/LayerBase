import 'package:flutter/material.dart';
import 'package:layerbase/utils/constants/app_constants.dart';

import '../../constants/app_color.dart';

class BaseTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;
  final InputBorder? border;
  final Color? fillColor;
  final Color? hintTextColor;
  final bool filled;
  final FocusNode? focusNode;

  const BaseTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.border,
    this.focusNode,
    this.fillColor = AppColors.lightGrey,
    this.hintTextColor = AppColors.greyColor,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      cursorColor: Colors.white,
      style: TextStyle(color: AppColors.greyColor, fontSize: fontSize16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: filled,
        errorMaxLines: 2,
        hintStyle: TextStyle(color: hintTextColor ?? AppColors.greyColor, fontSize: fontSize16),
        fillColor: fillColor ?? Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: spacerSize8, vertical: 0),
        border:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacerSize16),
              borderSide: BorderSide(color: AppColors.greyColor),
            ),
        enabledBorder:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacerSize16),
              borderSide: BorderSide(color: AppColors.greyColor),
            ),
        focusedBorder:
            border ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(spacerSize16),
              borderSide: const BorderSide(color: AppColors.greyColor, width: 1.5),
            ),
      ),
    );
  }
}
