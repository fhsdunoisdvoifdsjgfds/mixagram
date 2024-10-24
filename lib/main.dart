import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/MainScreen.dart';
import 'loading/LoadingScreen.dart';
import 'onboarding/OnBoardingScreen.dart';
import 'settings/audio_play.dart'; // Импортируем экран онбординга

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LaunchScreen(),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Future<bool> checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('firstRun') ?? true;

    if (isFirstRun) {
      await prefs.setInt('coins', 250);
      await prefs.setBool('firstRun', false);
    }

    final isOnboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    return isOnboardingComplete;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstRun(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else {
          if (snapshot.hasData && !snapshot.data!) {
            return OnBoardingScreen(
              onComplete: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboardingComplete', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreenGame(),
                  ),
                );
              },
            );
          } else {
            return const MainScreenGame();
          }
        }
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager().initAudio();
  runApp(const MyApp());
}
