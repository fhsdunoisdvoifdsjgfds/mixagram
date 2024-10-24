import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnBoardingScreen({Key? key, required this.onComplete})
      : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _buildPage(
            backgroundImage: 'assets/bg/splash_1_page.png',
            backImage: 'assets/bg/splash_1_page_book.png',
            title:
                'Sweet Mixagram is a daily word puzzle that will put your vocabulary skills to the test.',
            description:
                'Start by creating a  word from the set of provided letters. As you progress, the challenge intensifies. Each level pushes your thinking and creativity to find the right combinations.',
            pageIndex: 0,
          ),
          _buildPage(
            backgroundImage: 'assets/bg/splash_1_page.png',
            backImage: 'assets/bg/splash_2_page.png',
            title: '',
            description:
                'Think you’ve got what it takes to solve all the word puzzles? Get ready to dive into Sweet Mixagram and see how far your word skills can take you!',
            pageIndex: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String backgroundImage,
    required String backImage,
    required String title,
    required String description,
    required int pageIndex,
  }) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: pageIndex == 0
                  ? Image.asset(backImage)
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage(backImage))),
                    ),
            ),
            pageIndex == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: MediaQuery.of(context).size.height * .15,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.8),
                        ),
                        child: Center(
                          child: Text(
                            title,
                            style: GoogleFonts.baloo2(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * .25,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      description,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * .1,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (pageIndex == 0) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            widget.onComplete();
                          }
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/btz.png'),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Next',
                              style: GoogleFonts.baloo2(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
