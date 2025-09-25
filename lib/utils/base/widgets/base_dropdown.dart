import 'package:flutter/material.dart';
import 'package:layerbase/utils/constants/app_color.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';

class BaseDropdown extends StatelessWidget {
  const BaseDropdown({super.key, this.labelText, this.items, this.onChanged});

  final String? labelText;
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      padding: EdgeInsets.zero,
      isExpanded: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      borderRadius: BorderRadius.circular(spacerSize10),
      style: TextStyle(
        color: AppColors.greyColor,
        fontSize: fontSize14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: spacerSize8),
        hintText: "",
        hintStyle: TextStyle(color: AppColors.greyColor, fontSize: fontSize16),
        suffixIcon: IconButton(
          style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
          onPressed: () {},
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.lightPink,
            size: spacerSize20,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacerSize16),
          borderSide: BorderSide(color: AppColors.greyColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacerSize16),
          borderSide: BorderSide(color: AppColors.greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacerSize16),
          borderSide: const BorderSide(color: AppColors.greyColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacerSize16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacerSize16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),

      validator: (value) {
        if (value == null) {
          return AppStrings.required;
        }
        return null;
      },
      items: items,
      onChanged: onChanged,
    );
  }
}
