// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:mixagram/game/MainScreen.dart';
import 'package:mixagram/game/data.dart';
import 'dart:async';

import 'widgets/pause.dart';

late List<String> availableLetters;
late List<String> possibleWords;

class StartGamePage extends StatefulWidget {
  final int letters;
  const StartGamePage({super.key, required this.letters});

  @override
  State<StartGamePage> createState() => _StartGamePageState();
}

class _StartGamePageState extends State<StartGamePage> {
  int hint = 1;
  int coins = 100;
  bool timeOut = false;
  String currentWord = '';
  List<String> foundWords = [];
  final AudioPlayer successPlayer = AudioPlayer();
  final AudioPlayer failurePlayer = AudioPlayer();
  final AudioPlayer victoryPlayer = AudioPlayer();
  late Timer gameTimer;
  int remainingSeconds = 100;
  bool isPaused = false;
  bool isWin = false;

  @override
  void initState() {
    super.initState();
    availableLetters = levelLetters[widget.letters] ?? [];
    possibleWords = levelWords[widget.letters] ?? [];
    loadSounds();
    startTimer();
  }

  @override
  void dispose() {
    successPlayer.dispose();
    failurePlayer.dispose();
    victoryPlayer.dispose();
    gameTimer.cancel();
    super.dispose();
  }

  void loadSounds() async {
    await successPlayer.setSource(AssetSource('music/complete_word.mp3'));
    await failurePlayer.setSource(AssetSource('music/time_out.mp3'));
    await victoryPlayer.setSource(AssetSource('music/end_level.mp3'));
  }

  void startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            timer.cancel();
            showTimeUpDialog();
          }
        });
      }
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void handleSkip() {
    if (coins >= 10 && foundWords.length < 5) {
      setState(() {
        String newWord = possibleWords.firstWhere(
          (word) => !foundWords.contains(word),
          orElse: () => '',
        );

        if (newWord.isNotEmpty) {
          foundWords.add(newWord);
          coins = math.max(0, coins - 10);

          if (foundWords.length == 5) {
            victoryPlayer.resume();
            setState(() {
              isWin = true;
            });
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins or all words found!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void handleRandom() {
    if (coins >= 60) {
      setState(() {
        foundWords.clear();
        final shuffledWords = List<String>.from(possibleWords)..shuffle();
        foundWords.addAll(shuffledWords.take(5));
        coins = math.max(0, coins - 60);
        victoryPlayer.resume();
        setState(() {
          isWin = true;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void showTimeUpDialog() {
    failurePlayer.resume();
    setState(() {
      coins = math.max(0, coins - 10);
      timeOut = true;
      isWin = true;
    });
  }

  Future<bool> isValidEnglishWord(String word) async {
    if (isPaused) return false;
    try {
      final response = await http.get(Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${word.toLowerCase()}'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void onLetterTap(String letter) {
    if (isPaused) return;
    setState(() {
      if (currentWord.length < widget.letters) {
        currentWord += letter;
        if (currentWord.length == widget.letters) {
          checkWord();
        }
      }
    });
  }

  void checkWord() async {
    if (currentWord.length == widget.letters) {
      if (possibleWords.contains(currentWord) &&
          !foundWords.contains(currentWord)) {
        successPlayer.resume();
        setState(() {
          foundWords.add(currentWord);
          currentWord = '';
          coins += 10;
          if (foundWords.length == 5) {
            victoryPlayer.resume();
            showWinDialog();
          }
        });
      } else {
        setState(() {
          currentWord = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid word or already found'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void handleHint() {
    if (hint > 0) {
      final remainingWords =
          possibleWords.where((word) => !foundWords.contains(word)).toList();
      if (remainingWords.isNotEmpty) {
        setState(() {
          String wordToHint = remainingWords.first;
          int lettersToShow = 1; // показываем только одну букву за раз
          if (currentWord.isEmpty) {
            currentWord = wordToHint.substring(0, lettersToShow);
          }
          hint--;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hints left!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void showWinDialog() {
    gameTimer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content:
            Text('You found 5 words in ${formatTime(180 - remainingSeconds)}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                foundWords.clear();
                currentWord = '';
                remainingSeconds = 180;
                startTimer();
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(levelBackgrounds[widget.letters] ??
                'assets/bg/start_game_page.png'),
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
                      onTap: togglePause,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/pause.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .3,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/coins.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Center(
                          child: Text(
                            '$coins',
                            style: GoogleFonts.baloo2(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .25,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/timer.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          formatTime(remainingSeconds),
                          style: GoogleFonts.baloo2(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8, // расстояние между буквами
                  runSpacing: 8, // расстояние между рядами
                  children: List.generate(widget.letters, (index) {
                    return GestureDetector(
                      onTap: () => onLetterTap(availableLetters[index]),
                      child: Container(
                        width:
                            45, // уменьшим размер для большего количества букв
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            availableLetters[index],
                            style: GoogleFonts.baloo2(
                              fontSize: 24, // уменьшим размер шрифта
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/book.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Center(
                    child: Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width * .72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.letters, (index) {
                          return Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: index < currentWord.length
                                    ? letterColors[index % letterColors.length]
                                    : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                index < currentWord.length
                                    ? currentWord[index]
                                    : '',
                                style: GoogleFonts.baloo2(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: index < currentWord.length
                                      ? letterColors[
                                          index % letterColors.length]
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWordContainer(0),
                        const SizedBox(width: 10),
                        _buildWordContainer(1),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWordContainer(2),
                        const SizedBox(width: 10),
                        _buildWordContainer(3),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildWordContainer(4),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width * .9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: handleSkip,
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * .25,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/icons/btn_bottom_play.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SKIP',
                            style: GoogleFonts.baloo2(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: handleRandom,
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * .25,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/icons/btn_bottom_play.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Image.asset('assets/images/random.png'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: handleHint,
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * .25,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/icons/btn_bottom_play.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'HINT ($hint)',
                            style: GoogleFonts.baloo2(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            if (isPaused) _buildPauseOverlay(),
            if (isWin) _buildWinOverlay(timeOut),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        Center(
          child: PauseMenu(
            onResume: togglePause,
            onRestart: () {
              setState(() {
                foundWords.clear();
                currentWord = '';
                remainingSeconds = 180;
                isPaused = false;
              });
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainScreenGame(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWinOverlay(bool isTime) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
        ),
        Center(
          child: WinMenu(
            onRestart: () {
              setState(() {
                foundWords.clear();
                currentWord = '';
                remainingSeconds = 180;
                isPaused = false;
              });
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainScreenGame(),
                ),
                (Route<dynamic> route) => false,
              );
            },
            timeFall: isTime,
          ),
        ),
      ],
    );
  }

  Widget _buildWordContainer(int index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 50,
      decoration: BoxDecoration(
        color: index < foundWords.length
            ? const Color(0xFFFFE15C)
            : const Color(0xFFD2D2D2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: index < foundWords.length
              ? const Color(0xFFFFE15C)
              : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          index < foundWords.length ? foundWords[index] : '',
          style: GoogleFonts.baloo2(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: index < foundWords.length ? const Color(0xFF343434) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
