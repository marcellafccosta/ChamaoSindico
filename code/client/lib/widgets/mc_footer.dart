import 'package:flutter/material.dart';

class McFooter extends StatelessWidget {
  const McFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: _getTheme(context),
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: (int index) {},
        ),
      ),
    );
  }
  // ThemeData _getTheme(BuildContext context) {
  //   final shortestSide = MediaQuery.of(context).size.shortestSide;
  //   final isSmall = shortestSide < 380;
  //   return ThemeData(
  //     colorScheme: ColorScheme.fromSeed(seedColor: azulEscuro),
  //     useMaterial3: true,
  //     navigationBarTheme: NavigationBarThemeData(
  //       backgroundColor: azulClaro,
  //       indicatorColor: azulEscuro.withAlpha(50),
  //       elevation: 3,
  //       labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
  //         final fontSize = isSmall ? 10.0 : 14.0;
  //         if (states.contains(WidgetState.selected)) {
  //           return TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: azulEscuro,
  //               fontSize: fontSize);
  //         }
  //         return TextStyle(color: Colors.black54, fontSize: fontSize);
  //       }),
  //       iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
  //         return IconThemeData(
  //             color: states.contains(WidgetState.selected)
  //                 ? azulEscuro
  //                 : Colors.black54);
  //       }),
  //     ),
  //   );
  // }
}
