import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget levelBox(BuildContext context, String text, bool isActive, int price) {
  return Container(
    height: MediaQuery.of(context).size.height * .08,
    width: MediaQuery.of(context).size.width * .4,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: isActive
            ? const AssetImage('assets/images/active_level.png')
            : const AssetImage('assets/images/in_active_level.png'),
      ),
    ),
    child: Stack(
      children: [
        !isActive && price != 0
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 40,
                  width: 70,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/price.png'),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Center(
                      child: Text(
                        price.toString(),
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
