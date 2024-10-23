import 'dart:ui';

const List<Color> letterColors = [
  Color(0xFF4CAF50),
  Color(0xFF2196F3),
  Color(0xFFFFC107),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
];

Map<int, List<String>> levelWords = {
  5: ['STARE', 'TEARS', 'RATES', 'TASER', 'EARTH'],
  6: ['MASTER', 'STREAM', 'REMAIN', 'TAMERS', 'DREAMS'],
  7: ['PLAYING', 'GAINING', 'EXPLAIN', 'PAINTER', 'RAINING'],
  8: ['STRANGER', 'GARDENS', 'TRENDING', 'STANDING', 'TRAINING'],
};

Map<int, List<String>> levelLetters = {
  5: ['S', 'T', 'A', 'R', 'E'],
  6: ['M', 'A', 'S', 'T', 'E', 'R'],
  7: ['P', 'L', 'A', 'Y', 'I', 'N', 'G'],
  8: ['S', 'T', 'R', 'A', 'N', 'G', 'E', 'R'],
};
Map<int, String> levelBackgrounds = {
  5: 'assets/bg/level_5_bg.png',
  6: 'assets/bg/level_6_bg.png',
  7: 'assets/bg/level_7_bg.png',
  8: 'assets/bg/level_8_bg.png',
};
