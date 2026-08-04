import 'package:flutter/material.dart';

class BaseForm extends StatelessWidget {
  const BaseForm({super.key, this.child, this.formKey});

  final Widget? child;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUnfocus,
      key: formKey,
      child: child ?? SizedBox(),
    );
  }
}
