import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CreateReceiveRequestViewModel extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  bool showOffer = false;
  bool isCrossSelected = false;
  bool isGameToGoing = false;
  bool isLoading = false;

  final TextEditingController sdpController = TextEditingController();
  final TextEditingController popupController = TextEditingController();

  Future<void> initializePeerConnection() async {
    if (_peerConnection != null) return;
    _setLoading(true);

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onIceCandidate = (candidate) {
      print("ICE Candidate: ${jsonEncode(candidate.toMap())}");
    };

    _peerConnection!.onIceConnectionState = (state) {
      print("ICE Connection State: $state");
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        print("✅ Connected to peer!");
        isCrossSelected = true;
        _dataChannel?.send(RTCDataChannelMessage("Hello from this side!"));

        Future.delayed(const Duration(seconds: 1), () {
          _goToGameScreen();
        });
      }
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };

    _setLoading(false);
  }

  void _setupDataChannel() {
    _dataChannel?.onMessage = (msg) {
      isCrossSelected = false;
      print("📩 Received: ${msg.text}");
    };
  }

  Future<void> createOffer() async {
    _setLoading(true);

    _dataChannel = await _peerConnection!.createDataChannel("chat", RTCDataChannelInit());
    _setupDataChannel();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _peerConnection!.onIceGatheringState = (state) async {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        final desc = await _peerConnection!.getLocalDescription();
        sdpController.text = jsonEncode(desc!.toMap());
        showOffer = true;
        _setLoading(false);
        notifyListeners();
      }
    };
  }

  Future<void> showReceiveDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Paste Offer JSON"),
        content: TextField(
          controller: popupController,
          maxLines: 10,
          decoration: const InputDecoration(hintText: "Paste offer here"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _setLoading(true);
              final offer = jsonDecode(popupController.text);

              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(offer['sdp'], offer['type']),
              );

              final answer = await _peerConnection!.createAnswer();
              await _peerConnection!.setLocalDescription(answer);

              _peerConnection!.onIceGatheringState = (state) async {
                if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
                  final desc = await _peerConnection!.getLocalDescription();
                  Navigator.pop(ctx);

                  _setLoading(false);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Share this Answer"),
                      content: SelectableText(jsonEncode(desc!.toMap())),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        )
                      ],
                    ),
                  );
                }
              };
            },
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

  Future<void> showAnswerInputDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Paste Answer JSON"),
        content: TextField(
          controller: popupController,
          maxLines: 10,
          decoration: const InputDecoration(hintText: "Paste answer here"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final answer = jsonDecode(popupController.text);
              await _peerConnection!.setRemoteDescription(
                RTCSessionDescription(answer['sdp'], answer['type']),
              );
              Navigator.pop(ctx);
            },
            child: const Text("Finish Connection"),
          ),
        ],
      ),
    );
  }

  void _goToGameScreen() {
    isGameToGoing = true;
    // Navigate to game screen
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _peerConnection?.close();
    sdpController.dispose();
    popupController.dispose();
    super.dispose();
  }
}

