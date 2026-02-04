import 'package:flutter/material.dart';

void main() {
  runApp(const MonJeu());
}

class MonJeu extends StatelessWidget {
  const MonJeu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mugen Haïti',
      debugShowCheckedModeBanner: false,
      home: PageJeu(),
    );
  }
}

// On re-transforme notre page en "StatefulWidget" pour pouvoir
// sauvegarder et modifier la position du personnage.
class PageJeu extends StatefulWidget {
  const PageJeu({Key? key}) : super(key: key);

  @override
  State<PageJeu> createState() => _EtatPageJeu();
}

class _EtatPageJeu extends State<PageJeu> {
  // On définit une position X et Y pour notre personnage.
  // Pour l'instant, on met des valeurs fixes pour tester.
  double _positionX = 150.0;
  double _positionY = 250.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      // On utilise un "Stack" pour nous permettre de superposer des widgets.
      // C'est parfait pour placer un personnage sur un fond.
      body: Stack(
        children: [
          Positioned(
            left: _positionX,
            top: _positionY,
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
        ],
      ),
    );
  }
}