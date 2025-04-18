import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_clash/constants/app_strings.dart';

class EnterUserDetailsViewModel with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  bool isCrossSelected = false;

  void toggleSelection(bool crossSelected) {
    isCrossSelected = crossSelected;
    notifyListeners();
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.PleaseEnterYourName;
    }
    return null;
  }
}
