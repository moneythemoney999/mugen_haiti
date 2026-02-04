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
  // Position du personnage
  double _positionX = 0.0;
  double _positionY = 0.0;

  @override
  void initState() {
    super.initState();
    // On exécute ce code après que la première frame a été dessinée.
    // C'est la méthode la plus sûre pour obtenir la taille de l'écran.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final tailleEcran = MediaQuery.of(context).size;
        // On met à jour l'état pour positionner le personnage au centre
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
      body: GestureDetector(
        onPanUpdate: (details) {
          // On met à jour la position du personnage en fonction du glissement du doigt
          setState(() {
            _positionX = details.globalPosition.dx;
            _positionY = details.globalPosition.dy;
          });
        },
        child: Stack(
          children: [
            // On affiche le personnage seulement si sa position a été initialisée
            if (_positionX != 0.0 && _positionY != 0.0)
              Positioned(
                left: _positionX - 25, // On décale de la moitié de la largeur pour centrer
                top: _positionY - 25,  // On décale de la moitié de la hauteur pour centrer
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