import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_clash/constants/app_strings.dart';
import 'package:tic_tac_clash/viewmodels/create_request_receive_viewmodel.dart';
import 'package:tic_tac_clash/viewmodels/enter_user_details_view_model.dart';
import 'package:tic_tac_clash/views/enter_user_details_Screen.dart';
import 'package:tic_tac_clash/views/welcome_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EnterUserDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => CreateReceiveRequestViewModel(),),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: WelcomeScreen(),
    );
  }
}
