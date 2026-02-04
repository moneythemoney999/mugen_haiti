import 'package:flutter/material.dart';

void main() {
  runApp(const MonJeu());
}

class MonJeu extends StatelessWidget {
  const MonJeu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mugen Haïti',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PageJeu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PageJeu extends StatefulWidget {
  const PageJeu({Key? key}) : super(key: key);

  @override
  _EtatPageJeu createState() => _EtatPageJeu();
}

class _EtatPageJeu extends State<PageJeu> {
  // Position initiale du personnage (sera mise à jour au centre)
  double _positionX = 0.0;
  double _positionY = 0.0;
  bool _aInitialise = false;

  @override
  Widget build(BuildContext context) {
    // Initialiser la position au centre de l'écran une seule fois
    if (!_aInitialise) {
      final tailleEcran = MediaQuery.of(context).size;
      _positionX = tailleEcran.width / 2;
      _positionY = tailleEcran.height / 2;
      _aInitialise = true;
    }

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _positionX = details.globalPosition.dx;
            _positionY = details.globalPosition.dy;
          });
        },
        child: Stack(
          children: [
            Positioned(
              left: _positionX - 25, // Centrer le personnage
              top: _positionY - 25,  // Centrer le personnage
              child: Container(
                width: 50,
                height: 50,
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
                      fontSize: 16,
                    ),
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