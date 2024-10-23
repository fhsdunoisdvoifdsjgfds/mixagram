import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _startLoading() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isDisposed) {
        setState(() {
          _progress = 1.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 100), _updateProgress);
  }

  void _updateProgress() {
    if (!_isDisposed && _progress < 1.0) {
      setState(() {
        _progress += 0.2;
      });
      Future.delayed(const Duration(milliseconds: 100), _updateProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/loading_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: MediaQuery.of(context).size.height * .6,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg/loading_page_pers.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * .6,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bg/loading_page_cloud.png'),
                    fit: BoxFit.cover,
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
