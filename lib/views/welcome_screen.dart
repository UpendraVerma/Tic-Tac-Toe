import 'package:flutter/material.dart';
import 'package:tic_tac_clash/constants/app_strings.dart';
import 'package:tic_tac_clash/views/enter_multiplayer_details_screen.dart';
import 'package:tic_tac_clash/views/enter_user_details_Screen.dart';
import '../constants/app_colors.dart';
import '../generated/assets.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Image.asset(
                Assets.imagesTicToeWelcome,
                height: 180,
              ),
              const SizedBox(height: 40),
              Text(
                AppStrings.appTitle,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.playWithFriendOrAI,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 50),
              CustomButton(
                title: AppStrings.multiplayerGame,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateReceiveRequest(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                title: AppStrings.playWithAI,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnterUserDetailsScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.secondary,
              ),
              const Spacer(),
              Text(
                AppStrings.madeWithLove,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
