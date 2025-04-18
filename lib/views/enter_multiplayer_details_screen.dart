import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_clash/constants/app_colors.dart';
import 'package:tic_tac_clash/widgets/custom_button.dart';

import '../viewmodels/create_request_receive_viewmodel.dart';

class CreateReceiveRequest extends StatelessWidget {
  const CreateReceiveRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateReceiveRequestViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Tic Tac Clash")),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await viewModel.initializePeerConnection();
                    await viewModel.createOffer();
                  },
                  child: const Text("Create Offer"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await viewModel.initializePeerConnection();
                    await viewModel.showReceiveDialog(context);
                  },
                  child: const Text("Receive Offer"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await viewModel.showAnswerInputDialog(context);
                  },
                  child: const Text("Enter Answer"),
                ),
              ],
            ),
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

