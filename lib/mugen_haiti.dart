import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import nécessaire pour SystemChrome

// La fonction main devient "async" pour pouvoir utiliser "await"
void main() async {
  // On s'assure que tout est prêt avant de définir l'orientation
  WidgetsFlutterBinding.ensureInitialized();

  // On force le mode paysage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // On lance l'application
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
  // Ces variables suivent la position globale du personnage
  double _positionXPersonnage = 0.0;
  double _positionYPersonnage = 0.0;

  // Variables pour le mouvement du joystick (seront mises à jour par le listener)
  double _mouvementJoystickX = 0.0;
  double _mouvementJoystickY = 0.0;

  bool _estInitialise = false; // Pour l'initialisation du personnage au centre

  @override
  void initState() {
    super.initState();
    // On s'assure que tout est prêt pour le centrage initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tailleEcran = MediaQuery.of(context).size;
      setState(() {
        _positionXPersonnage = tailleEcran.width / 2;
        _positionYPersonnage = tailleEcran.height / 2;
        _estInitialise = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        fit: StackFit.expand, // Le Stack principal pour superposer le personnage sur les contrôles
        children: [
          // Layout principal avec le Joystick et la zone Caméra
          Row(
            children: [
              // Zone Joystick (partie gauche de l'écran)
              Expanded(
                flex: 1, // Prend 1/3 de l'écran
                child: Container(
                  color: Colors.grey[700], // Couleur pour distinguer la zone joystick
                  child: Align(
                    alignment: const Alignment(0, 0.7), // Aligne le joystick un peu vers le bas
                    child: Joystick(
                      listener: (details) {
                        setState(() {
                          _mouvementJoystickX = details.x;
                          _mouvementJoystickY = details.y;
                          // Pour l'instant, on déplace le personnage directement avec le joystick
                          // Plus tard, cette logique sera plus complexe pour le mouvement du jeu
                          // On multiplie par 5 pour une vitesse visible
                          _positionXPersonnage += details.x * 5;
                          _positionYPersonnage += details.y * 5;
                        });
                      },
                      // Personnalisation du joystick
                      base: JoystickBase(
                        decoration: JoystickBaseDecoration(
                          color: Colors.blueGrey.shade800,
                          strokeColor: Colors.blueGrey.shade400,
                          drawOuterCircle: true,
                        ),
                      ),
                      stick: JoystickStick(
                        decoration: JoystickStickDecoration(
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Zone Caméra (partie droite de l'écran)
              Expanded(
                flex: 2, // Prend 2/3 de l'écran
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent, // Détecte les gestes sur toute la surface
                  onPanUpdate: (details) {
                    setState(() {
                      // Pour le moment, cette zone déplace aussi le personnage pour simuler la caméra
                      // Plus tard, ici on déplacera la caméra, pas le personnage
                      _positionXPersonnage += details.delta.dx;
                      _positionYPersonnage += details.delta.dy;
                    });
                  },
                  child: Container(
                    color: Colors.grey[600], // Couleur pour distinguer la zone caméra
                    // Le contenu de la scène de jeu irait ici
                  ),
                ),
              ),
            ],
          ),

          // Le personnage est toujours un enfant direct du Stack principal pour pouvoir être positionné
          if (_estInitialise)
            Positioned(
              left: _positionXPersonnage - 50,
              top: _positionYPersonnage - 50,
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