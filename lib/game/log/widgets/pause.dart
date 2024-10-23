import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .85,
      height: MediaQuery.of(context).size.height * .5,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage('assets/images/bg_pause.png')),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 40,
          ),
          Text(
            'PAUSED',
            style: GoogleFonts.baloo2(
              fontSize: 55,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onResume,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width * .4,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/continue.png'))),
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: onRestart,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width * .4,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/quit.png'))),
            ),
          ),
        ],
      ),
    );
  }
}

class WinMenu extends StatelessWidget {
  final bool timeFall;
  final VoidCallback onRestart;

  const WinMenu({
    super.key,
    required this.onRestart,
    required this.timeFall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .85,
      height: MediaQuery.of(context).size.height * .5,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage('assets/images/bg_pause.png')),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                height: 250,
                width: 250,
                child: !timeFall
                    ? Image.asset('assets/images/textWin.png')
                    : Image.asset('assets/images/textLose.png'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: onRestart,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * .4,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/quit.png'))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
