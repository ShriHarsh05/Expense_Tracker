// import 'package:flutter/material.dart';

// class AppTheme {
//   static ThemeData lightTheme(Color accentColor) {
//     final colorScheme = ColorScheme.fromSeed(seedColor: accentColor);
//     return ThemeData().copyWith(
//       colorScheme: colorScheme,
//       useMaterial3: true,
//       appBarTheme: AppBarTheme(
//         backgroundColor: colorScheme.onPrimaryContainer,
//         foregroundColor: colorScheme.primaryContainer,
//       ),
//       cardTheme: CardThemeData(
//         color: colorScheme.secondaryContainer,
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorScheme.primaryContainer,
//         ),
//       ),
//       textTheme: ThemeData().textTheme.copyWith(
//             titleLarge: TextStyle(
//               fontWeight: FontWeight.normal,
//               color: colorScheme.onSecondaryContainer,
//               fontSize: 24,
//             ),
//           ),
//     );
//   }

//   static ThemeData darkTheme(Color accentColor) {
//     final colorScheme = ColorScheme.fromSeed(
//       seedColor: accentColor,
//       brightness: Brightness.dark,
//     );
//     return ThemeData.dark().copyWith(
//       colorScheme: colorScheme,
//       useMaterial3: true,
//       iconTheme: IconThemeData(color: colorScheme.onSurface),
//       appBarTheme: AppBarTheme(
//         backgroundColor: colorScheme.onPrimaryContainer,
//         foregroundColor: colorScheme.primaryContainer,
//       ),
//       cardTheme: CardTheme(
//         color: colorScheme.secondaryContainer,
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorScheme.primaryContainer,
//           foregroundColor: colorScheme.onPrimaryContainer,
//         ),
//       ),
//       textTheme: ThemeData.dark().textTheme.copyWith(
//             titleLarge: TextStyle(
//               fontWeight: FontWeight.normal,
//               color: colorScheme.onSecondaryContainer,
//               fontSize: 24,
//             ),
//             bodyLarge: ThemeData.dark()
//                 .textTheme
//                 .bodyLarge
//                 ?.copyWith(color: colorScheme.onSurface),
//             bodyMedium: ThemeData.dark()
//                 .textTheme
//                 .bodyMedium
//                 ?.copyWith(color: colorScheme.onSurface),
//           ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(Color accentColor) {
    final colorScheme = ColorScheme.fromSeed(seedColor: accentColor);
    return ThemeData().copyWith(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.onPrimaryContainer,
        foregroundColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardTheme(
        color: colorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.normal,
              color: colorScheme.onSecondaryContainer,
              fontSize: 24,
            ),
          ),
    );
  }

  static ThemeData darkTheme(Color accentColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    );
    return ThemeData.dark().copyWith(
      colorScheme: colorScheme,
      useMaterial3: true,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.onPrimaryContainer,
        foregroundColor: colorScheme.primaryContainer,
      ),
      cardTheme: CardTheme(
        color: colorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.normal,
              color: colorScheme.onSecondaryContainer,
              fontSize: 24,
            ),
            bodyLarge: ThemeData.dark()
                .textTheme
                .bodyLarge
                ?.copyWith(color: colorScheme.onSurface),
            bodyMedium: ThemeData.dark()
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.onSurface),
          ),
    );
  }
}
