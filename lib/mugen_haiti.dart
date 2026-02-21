import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import nécessaire pour SystemChrome
import 'dart:math' as math; // Pour les calculs mathématiques comme sqrt et atan2

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
  // Variable pour l'angle d'orientation visuelle du personnage (en radians)
  double _angleOrientationPersonnage = 0.0;

  // Variables pour le déplacement du personnage (vitesses horizontale et verticale écran-relative)
  double _vitesseHorizontalePersonnage = 0.0;
  double _vitesseVerticalePersonnage = 0.0;

  // Variables pour la rotation de la caméra (mises à jour par le glissement sur la zone droite)
  // Elles représentent le delta de mouvement et non l'angle absolu
  double _deltaRotationCameraX = 0.0;
  double _deltaRotationCameraY = 0.0;


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
    // === LOGIQUE DE MISE À JOUR DU PERSONNAGE (MOUVEMENT ÉCRAN-RELATIF) ===
    _positionXPersonnage += _vitesseHorizontalePersonnage * 5; // Multiplicateur de vitesse
    _positionYPersonnage += _vitesseVerticalePersonnage * 5; // Multiplicateur de vitesse

    // Mise à jour de l'angle d'orientation visuelle par la zone caméra
    _angleOrientationPersonnage += _deltaRotationCameraX * 0.01; // Sensibilité de la rotation
    if (_angleOrientationPersonnage > 2 * math.pi) _angleOrientationPersonnage -= 2 * math.pi;
    if (_angleOrientationPersonnage < 0) _angleOrientationPersonnage += 2 * math.pi;


    // Limitation du personnage aux bords de l'écran (simple)
    final tailleEcran = MediaQuery.of(context).size;
    _positionXPersonnage = _positionXPersonnage.clamp(50.0, tailleEcran.width - 50.0);
    _positionYPersonnage = _positionYPersonnage.clamp(50.0, tailleEcran.height - 50.0);

    // === LOGIQUE DE LA ZONE CAMÉRA (feedback visuel) ===
    // On convertit les deltas de rotation en un facteur de 0 à 1 pour la couleur
    double facteurCouleurX = (_deltaRotationCameraX.abs() / 100).clamp(0.0, 1.0);
    double facteurCouleurY = (_deltaRotationCameraY.abs() / 100).clamp(0.0, 1.0);
    double intensiteTotale = math.max(facteurCouleurX, facteurCouleurY); // La plus forte influence

    // On crée une couleur de base et on la modifie
    Color couleurBase = Colors.grey[600]!;
    Color couleurActive = Colors.blue.shade300; // Une couleur plus vive pour l'activité

    Color couleurFondCamera = Color.lerp(couleurBase, couleurActive, intensiteTotale)!;


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
                    child: ControleurJoystick(
                      onMouvement: (x, y) {
                        setState(() {
                          _vitesseHorizontalePersonnage = x; // Axe X du stick pour le mouvement horizontal
                          _vitesseVerticalePersonnage = y;    // Axe Y du stick pour le mouvement vertical (négatif pour monter, positif pour descendre)
                        });
                      },
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
                      // Mise à jour des deltas de rotation pour la caméra
                      _deltaRotationCameraX = details.delta.dx;
                      _deltaRotationCameraY = details.delta.dy;

                      // La rotation du personnage est directement mise à jour ici
                      _angleOrientationPersonnage += _deltaRotationCameraX * 0.01; // Ajuster la sensibilité
                      if (_angleOrientationPersonnage > 2 * math.pi) _angleOrientationPersonnage -= 2 * math.pi;
                      if (_angleOrientationPersonnage < 0) _angleOrientationPersonnage += 2 * math.pi;

                    });
                  },
                  onPanEnd: (details) {
                    // Réinitialiser les deltas après la fin du glissement
                    setState(() {
                      _deltaRotationCameraX = 0.0;
                      _deltaRotationCameraY = 0.0;
                    });
                  },
                  child: Container(
                    color: couleurFondCamera, // Utilise la couleur calculée
                    // Le contenu de la scène de jeu irait ici
                    child: Center(
                      child: Text(
                        'Caméra: dX:${_deltaRotationCameraX.toInt()}, dY:${_deltaRotationCameraY.toInt()}',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
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
              child: Transform.rotate( // On ajoute la rotation visuelle du personnage
                angle: _angleOrientationPersonnage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center( // Le texte tourne avec le personnage
                    child: Transform.rotate( // Rotation inverse pour le texte
                      angle: -_angleOrientationPersonnage, // Pour que le texte reste lisible
                      child: const Text(
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
            ),
        ],
      ),
    );
  }
}

// Nouveau widget pour notre contrôleur de joystick personnalisé
class ControleurJoystick extends StatefulWidget {
  final Function(double x, double y) onMouvement;

  const ControleurJoystick({Key? key, required this.onMouvement}) : super(key: key);

  @override
  _EtatControleurJoystick createState() => _EtatControleurJoystick();
}

class _EtatControleurJoystick extends State<ControleurJoystick> {
  final double _rayonBase = 75; // Rayon du fond du joystick
  final double _rayonStick = 35; // Rayon du stick (la partie mobile)

  Offset _positionStick = Offset.zero; // Position relative du stick par rapport au centre

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        // Centrer le stick sur le point de contact initial
        Offset centreBase = Offset(_rayonBase, _rayonBase);
        Offset pointDeContactRelatif = details.localPosition;

        // Calculer le vecteur du point de contact par rapport au centre de la base
        Offset vecteurContact = pointDeContactRelatif - centreBase;

        // Limiter le stick à l'intérieur du rayon de la base
        double distance = vecteurContact.distance;
        if (distance > _rayonBase) {
          vecteurContact = Offset.fromDirection(vecteurContact.direction, _rayonBase);
        }
        setState(() {
          _positionStick = vecteurContact;
        });

        // Informe le parent du mouvement initial
        double xNormalise = _positionStick.dx / _rayonBase;
        double yNormalise = _positionStick.dy / _rayonBase;
        widget.onMouvement(xNormalise, yNormalise);
      },
      onPanUpdate: (details) {
        setState(() {
          // Calcule le déplacement du doigt par rapport au centre du joystick
          Offset centreBase = Offset(_rayonBase, _rayonBase);
          Offset pointDeContactRelatif = details.localPosition;

          Offset vecteurContact = pointDeContactRelatif - centreBase;

          // Limite le stick à l'intérieur du rayon de la base
          double distance = vecteurContact.distance;
          if (distance > _rayonBase) {
            vecteurContact = Offset.fromDirection(vecteurContact.direction, _rayonBase);
          }
          _positionStick = vecteurContact;


          // Normalise les valeurs de déplacement (-1.0 à 1.0)
          // Note: l'axe Y est inversé en Flutter (haut est 0, bas est max)
          // Pour un joystick de jeu, on veut souvent Y positif vers le haut.
          // On peut l'inverser ici si nécessaire: -_positionStick.dy
          double xNormalise = _positionStick.dx / _rayonBase;
          double yNormalise = _positionStick.dy / _rayonBase;

          widget.onMouvement(xNormalise, yNormalise); // Informe le parent du mouvement
        });
      },
      onPanEnd: (details) {
        setState(() {
          _positionStick = Offset.zero; // Le stick retourne au centre après relâchement
          widget.onMouvement(0.0, 0.0); // Informe le parent que le mouvement a cessé
        });
      },
      child: Container(
        width: _rayonBase * 2,
        height: _rayonBase * 2,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4), // Fond du joystick
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _positionStick,
            child: Container(
              width: _rayonStick * 2,
              height: _rayonStick * 2,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8), // Couleur du stick
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
