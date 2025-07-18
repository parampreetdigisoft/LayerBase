import 'package:Layerbase/utils/constants/app_color.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/app_strings.dart' show AppStrings;

class BaseDropdown extends StatelessWidget {
  const BaseDropdown({super.key, this.labelText, this.items, this.onChanged});

  final String? labelText;
  final List<DropdownMenuItem<dynamic>>? items;
  final Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      padding: EdgeInsets.zero,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUnfocus,
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
