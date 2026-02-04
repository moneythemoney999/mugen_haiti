import 'package:flutter/material.dart';

void main() {
  runApp(const MonJeu());
}

class MonJeu extends StatelessWidget {
  const MonJeu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On retire toute complexité pour ce test.
    return MaterialApp(
      title: 'Mugen Haïti',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Fond gris pour s'assurer que l'on ne regarde pas un widget blanc sur fond blanc.
        backgroundColor: Colors.grey[800],
        body: Center(
          // Centrer le personnage à l'écran.
          child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'MH',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}