// enter_user_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_clash/views/tic_tak_toe_screen.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../generated/assets.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../viewmodels/enter_user_details_view_model.dart';

class EnterUserDetailsScreen extends StatefulWidget {
  const EnterUserDetailsScreen({super.key});

  @override
  State<EnterUserDetailsScreen> createState() => _EnterUserDetailsScreenState();
}

class _EnterUserDetailsScreenState extends State<EnterUserDetailsScreen> {

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EnterUserDetailsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.enterUserDetails),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.enterNameHint,
                validator: viewModel.validateName,
              ),
              const SizedBox(height: 30),
              const Text(
                AppStrings.selectSign,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSignSelector(
                    context: context,
                    isSelected: viewModel.isCrossSelected,
                    label: AppStrings.cross,
                    imagePath: Assets.imagesCross,
                    onTap: () => viewModel.toggleSelection(true),
                  ),
                  const SizedBox(width: 40),
                  _buildSignSelector(
                    context: context,
                    isSelected: !viewModel.isCrossSelected,
                    label: AppStrings.circle,
                    imagePath: Assets.imagesCircle,
                    onTap: () => viewModel.toggleSelection(false),
                  ),
                ],
              ),
              const Spacer(),
              CustomButton(
                title: AppStrings.next,
                backgroundColor: AppColors.secondary,
                onPressed: () {
                  if (viewModel.validateForm()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TicTokToe(playerName: _nameController.text, isCrossSelected: viewModel.isCrossSelected, isFromMultiPlayer: false),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignSelector({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.lightGrey,
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 50, width: 50),
            const SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}
