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

class PageJeu extends StatefulWidget {
  const PageJeu({Key? key}) : super(key: key);

  @override
  State<PageJeu> createState() => _EtatPageJeu();
}

class _EtatPageJeu extends State<PageJeu> {
  double _positionX = 0.0;
  double _positionY = 0.0;
  // Ce drapeau nous dira si on peut afficher le personnage.
  bool _estInitialise = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final tailleEcran = MediaQuery.of(context).size;
        setState(() {
          // On calcule la position centrale...
          _positionX = tailleEcran.width / 2;
          _positionY = tailleEcran.height / 2;
          // ...et seulement maintenant, on autorise l'affichage.
          _estInitialise = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: GestureDetector(
        // CORRECTION 1: On dit au détecteur de fonctionner sur toute la surface.
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            _positionX = details.globalPosition.dx;
            _positionY = details.globalPosition.dy;
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // CORRECTION 2: On n'affiche le personnage que si le drapeau est vrai.
            // Il ne s'affichera donc qu'au centre, à la deuxième frame.
            if (_estInitialise)
              Positioned(
                left: _positionX - 50,
                top: _positionY - 50,
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
      ),
    );
  }
}