import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:tic_tac_clash/constants/app_colors.dart';
import 'package:tic_tac_clash/views/win_pattern_draw.dart';

class TicTokToe extends StatefulWidget {
  String playerName = "";
  bool isCrossSelected;
  bool isFromMultiPlayer;
  final RTCPeerConnection? peerConnection;
  final RTCDataChannel? dataChannel;

  TicTokToe({
    super.key,
    required this.playerName,
    required this.isCrossSelected,
    required this.isFromMultiPlayer,
    this.peerConnection,
    this.dataChannel,
  });

  @override
  State<TicTokToe> createState() => _TicTokToeState();
}

class _TicTokToeState extends State<TicTokToe> {
  String previousSelected = "";
  bool isCurrentGameWin = false;
  String currentWinnerName = "";
  List<int> winnerPattern = [];
  String currentPersonMove = "";
  bool myStepMove = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> ticList = List.generate(
    9,
    (index) => {"key": index, "value": ""},
  );

  final List<List<int>> winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  void selectedStep(int index) async {
    if (widget.isFromMultiPlayer) {
      if (myStepMove || ticList[index]["value"] != "") return;

      setState(() {
        myStepMove = true;
        ticList[index]["value"] = widget.isCrossSelected ? "*" : "0";
      });

      widget.dataChannel?.send(
        RTCDataChannelMessage('$index:${widget.isCrossSelected ? "*" : "0"}'),
      );

      checkWinStep();
    } else {
      if (isCurrentGameWin || ticList[index]["value"] != "") return;

      setState(() {
        previousSelected = previousSelected == "0" ? "*" : "0";
        previousSelected =
            previousSelected == ""
                ? (widget.isCrossSelected ? "*" : "0")
                : previousSelected;
        ticList[index]["value"] = previousSelected;
      });

      checkWinStep();

      if (!isCurrentGameWin && !checkAllSelected()) {
        _triggerAiMove(index);
      }
    }
  }

  void _triggerAiMove(int userIndex) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    aiMove(userIndex);
    setState(() => _isLoading = false);
  }

  void aiMove(int index) {
    String aiSign = widget.isCrossSelected ? "0" : "*";
    String userSign = widget.isCrossSelected ? "*" : "0";

    int? bestMove = findBestMove(aiSign) ?? findBestMove(userSign);

    if (bestMove == null && ticList[4]["value"] == "") {
      bestMove = 4;
    }

    bestMove ??= [
      0,
      2,
      6,
      8,
    ].firstWhere((i) => ticList[i]["value"] == "", orElse: () => -1);

    if (bestMove == -1) {
      bestMove = ticList.indexWhere((cell) => cell["value"] == "");
    }

    if (bestMove != -1) {
      setState(() {
        if (bestMove != null) {
          ticList[bestMove]["value"] = aiSign;
        }
        previousSelected = aiSign;
      });
      checkWinStep();
    }
  }

  int? findBestMove(String sign) {
    for (int i = 0; i < ticList.length; i++) {
      if (ticList[i]["value"] == "") {
        ticList[i]["value"] = sign;
        bool win = checkIfWinning(sign);
        ticList[i]["value"] = "";
        if (win) return i;
      }
    }
    return null;
  }

  bool checkIfWinning(String sign) {
    return winPatterns.any(
      (p) =>
          ticList[p[0]]["value"] == sign &&
          ticList[p[1]]["value"] == sign &&
          ticList[p[2]]["value"] == sign,
    );
  }

  void checkWinStep() {
    for (var pattern in winPatterns) {
      final a = ticList[pattern[0]]["value"];
      final b = ticList[pattern[1]]["value"];
      final c = ticList[pattern[2]]["value"];
      if (a.isNotEmpty && a == b && b == c) {
        setState(() {
          isCurrentGameWin = true;
          currentWinnerName = a;
          winnerPattern = pattern;
        });
        return;
      }
    }
  }

  bool checkAllSelected() => ticList.every((cell) => cell["value"] != "");

  @override
  void initState() {
    super.initState();
    if (widget.isFromMultiPlayer && widget.dataChannel != null) {
      widget.dataChannel!.onMessage = (message) {
        if (message.text == "restart_game") {
          setState(() {
            previousSelected = "";
            isCurrentGameWin = false;
            currentWinnerName = "";
            winnerPattern.clear();
            for (var cell in ticList) {
              cell["value"] = "";
            }
          });
        } else {
          final parts = message.text.trim().split(":");
          if (parts.length == 2) {
            int idx = int.parse(parts[0]);
            String val = parts[1];
            setState(() {
              myStepMove = false;
              if (ticList[idx]["value"] == "") {
                ticList[idx]["value"] = val;
                previousSelected = val;
                checkWinStep();
              }
            });
          }
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final String mySign = widget.isCrossSelected ? "*" : "0";
    final String aiSign = widget.isCrossSelected ? "0" : "*";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tic Tac Toe"),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("Player: ${widget.playerName}"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Your Sign: $mySign"),
              Text(
                widget.isFromMultiPlayer
                    ? "Opponent Sign: $aiSign"
                    : "AI Sign: $aiSign",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 300,
            width: 300,
            margin: const EdgeInsets.all(30),
            child: Stack(
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder:
                      (context, index) => GestureDetector(
                        onTap: () {
                          if (ticList[index]["value"] == "" &&
                              !isCurrentGameWin) {
                            selectedStep(index);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right:
                                  (index % 3 == 2)
                                      ? BorderSide.none
                                      : const BorderSide(
                                        width: 2,
                                        color: Colors.grey,
                                      ),
                              bottom:
                                  (index >= 6)
                                      ? BorderSide.none
                                      : const BorderSide(
                                        width: 2,
                                        color: Colors.grey,
                                      ),
                            ),
                          ),
                          child: Center(
                            child:
                                (ticList[index]["value"] != "")
                                    ? Text(
                                      ticList[index]["value"],
                                      style: const TextStyle(fontSize: 24),
                                    )
                                    : const SizedBox(),
                          ),
                        ),
                      ),
                ),
                if (winnerPattern.isNotEmpty)
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: WinLinePainter(winnerPattern),
                  ),

                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 12),
                          Text(
                            'AI is thinking...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isCurrentGameWin || checkAllSelected())
            Text(
              isCurrentGameWin
                  ? (currentWinnerName == mySign
                      ? "🎉 You Win!"
                      : "😢 You Lost")
                  : "🤝 It's a draw!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 20),
          (checkAllSelected() == true || isCurrentGameWin == true)
              ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    previousSelected = "";
                    isCurrentGameWin = false;
                    currentWinnerName = "";
                    winnerPattern = [];
                    for (var value in ticList) {
                      value["value"] = "";
                    }

                    widget.dataChannel?.send(
                      RTCDataChannelMessage('restart_game'),
                    );
                  });
                },
                child: const Text("Restart Game"),
              )
              : const Text(""),
        ],
      ),
    );
  }
}
