// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class BonusGameScreen extends StatefulWidget {
  const BonusGameScreen({super.key});

  @override
  State<BonusGameScreen> createState() => _BonusGameScreenState();
}

class _BonusGameScreenState extends State<BonusGameScreen> {
  final List<String> cardImages = [
    'assets/images/card1.png',
    'assets/images/card2.png',
    'assets/images/card3.png',
    'assets/images/card4.png',
    'assets/images/card5.png',
    'assets/images/card6.png',
    'assets/images/card7.png',
    'assets/images/card8.png',
  ];

  final String hiddenCardPath = 'assets/images/cardx.png';
  late List<String> gameCards;
  List<bool> cardsFlipped = [];
  List<bool> cardsMatched = [];
  int? firstCardIndex;
  bool canFlip = true;
  int currentLevel = 1;
  final int totalLevels = 5;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    gameCards = [...cardImages, ...cardImages];
    gameCards.shuffle();
    cardsFlipped = List.filled(16, false);
    cardsMatched = List.filled(16, false);
    firstCardIndex = null;
    canFlip = true;
  }

  void handleCardTap(int index) {
    if (!canFlip || cardsFlipped[index] || cardsMatched[index]) return;

    setState(() {
      cardsFlipped[index] = true;

      if (firstCardIndex == null) {
        firstCardIndex = index;
      } else {
        final firstCard = gameCards[firstCardIndex!];
        final secondCard = gameCards[index];

        if (firstCard == secondCard) {
          cardsMatched[firstCardIndex!] = true;
          cardsMatched[index] = true;
          firstCardIndex = null;

          if (cardsMatched.every((matched) => matched)) {
            Timer(const Duration(milliseconds: 500), () {
              levelCompleted();
            });
          }
        } else {
          canFlip = false;
          Timer(const Duration(milliseconds: 1000), () {
            setState(() {
              cardsFlipped[firstCardIndex!] = false;
              cardsFlipped[index] = false;
              firstCardIndex = null;
              canFlip = true;
            });
          });
        }
      }
    });
  }

  void levelCompleted() {
    if (currentLevel < totalLevels) {
      setState(() {
        currentLevel++;
        initializeGame();
      });
    } else {
      showWinDialog();
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You have completed all levels!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentLevel = 1;
                initializeGame();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/bonus_game_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 50,
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/icons/btn_arrow_back.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 50,
                      width: 100,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/level_index.png'),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$currentLevel/$totalLevels',
                          style: GoogleFonts.baloo2(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 70),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: MediaQuery.of(context).size.height * .5,
                width: MediaQuery.of(context).size.width * .9,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bonus_bg.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 40.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => handleCardTap(index),
                        child: AnimatedFlipCard(
                          isFlipped: cardsFlipped[index] || cardsMatched[index],
                          frontImage: hiddenCardPath,
                          backImage: gameCards[index],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedFlipCard extends StatelessWidget {
  final bool isFlipped;
  final String frontImage;
  final String backImage;

  const AnimatedFlipCard({
    super.key,
    required this.isFlipped,
    required this.frontImage,
    required this.backImage,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0,
        end: isFlipped ? 180 : 0,
      ),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        bool showFrontSide = value < 90;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((value * 3.1415926535897932 / 180)),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: showFrontSide
                ? Image.asset(
                    frontImage,
                    fit: BoxFit.contain,
                  )
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.1415926535897932),
                    alignment: Alignment.center,
                    child: Container(
                      child: Image.asset(
                        backImage,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
