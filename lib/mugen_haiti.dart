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
  // On initialise les positions à 0.
  double _positionX = 0.0;
  double _positionY = 0.0;

  @override
  void initState() {
    super.initState();
    // On utilise la méthode sûre pour centrer le personnage au démarrage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final tailleEcran = MediaQuery.of(context).size;
        setState(() {
          _positionX = tailleEcran.width / 2;
          _positionY = tailleEcran.height / 2;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      // Le GestureDetector détecte les gestes sur toute la surface de son enfant (le Stack).
      body: GestureDetector(
        // Cette fonction est appelée à chaque fois que le doigt glisse sur l'écran.
        onPanUpdate: (details) {
          // On met à jour l'état avec la nouvelle position du doigt.
          setState(() {
            _positionX = details.globalPosition.dx;
            _positionY = details.globalPosition.dy;
          });
        },
        child: Stack(
          // On rend le Stack transparent aux clics pour que le GestureDetector derrière fonctionne bien
          // sur toute la surface, même là où il n'y a pas de personnage.
          fit: StackFit.expand,
          children: [
            // NOTE POUR LE DÉBOGAGE : La condition "if" a été retirée pour forcer l'affichage.
            Positioned(
              // On soustrait la moitié de la taille du cercle pour qu'il soit
              // parfaitement centré sous le doigt, et non décalé.
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