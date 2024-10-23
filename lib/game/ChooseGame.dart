import 'package:flutter/material.dart';
import 'package:mixagram/game/log/StartGameScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log/widgets/level.dart';

class ChooseGameScreen extends StatefulWidget {
  const ChooseGameScreen({super.key});

  @override
  State<ChooseGameScreen> createState() => _ChooseGameScreenState();
}

class _ChooseGameScreenState extends State<ChooseGameScreen> {
  final Map<int, int> levelPrices = {
    6: 100,
    7: 200,
    8: 300,
  };

  Future<Map<String, dynamic>> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('coins')) {
      await prefs.setInt('coins', 500);
    }

    final coins = prefs.getInt('coins') ?? 500;
    final unlockedLevels = prefs.getStringList('unlockedLevels') ?? ['5'];

    return {
      'coins': coins,
      'unlockedLevels': unlockedLevels,
    };
  }

  Future<void> _purchaseLevel(int level, int price, int currentCoins) async {
    final prefs = await SharedPreferences.getInstance();

    if (currentCoins >= price) {
      await prefs.setInt('coins', currentCoins - price);
      final unlockedLevels = prefs.getStringList('unlockedLevels') ?? ['5'];
      unlockedLevels.add(level.toString());
      await prefs.setStringList('unlockedLevels', unlockedLevels);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadGameData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final coins = snapshot.data!['coins'] as int;
          final unlockedLevels =
              snapshot.data!['unlockedLevels'] as List<String>;
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg/choose_game_page.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 60,
                  left: 30,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/icons/btn_arrow_back.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Container(
                        height: MediaQuery.of(context).size.height * .08,
                        width: MediaQuery.of(context).size.width * .4,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/difficulty.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      coins.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const StartGamePage(letters: 5),
                            ),
                          );
                        },
                        child: levelBox(context, '5 letters', true, 0),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(3, (index) {
                        final level = index + 6;
                        final isUnlocked =
                            unlockedLevels.contains(level.toString());
                        final price = levelPrices[level]!;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isUnlocked) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => StartGamePage(
                                        letters: level,
                                      ),
                                    ),
                                  );
                                } else if (coins >= price) {
                                  _purchaseLevel(level, price, coins);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Not enough coins!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: levelBox(
                                  context, '$level letters', isUnlocked, price),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
