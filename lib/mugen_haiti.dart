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

  // Variables pour le déplacement du personnage (mises à jour par le joystick)
  double _deplacementPersonnageX = 0.0;
  double _deplacementPersonnageY = 0.0;

  // Variables pour la rotation de la caméra (mises à jour par le glissement sur la zone droite)
  double _rotationCameraX = 0.0;
  double _rotationCameraY = 0.0;

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
    // Calcul de la nouvelle position du personnage en fonction du joystick
    // On utilise _deplacementPersonnageX et Y
    if (_deplacementPersonnageX != 0 || _deplacementPersonnageY != 0) {
      _positionXPersonnage += _deplacementPersonnageX * 5; // Multiplicateur de vitesse
      _positionYPersonnage += _deplacementPersonnageY * 5; // Multiplicateur de vitesse
    }

    // Calcul de la couleur de fond de la zone caméra en fonction de la rotation
    // Plus on glisse, plus la couleur change (exemple simple)
    // On convertit les deltas de rotation en un facteur de 0 à 1 pour la couleur
    double facteurCouleurX = (_rotationCameraX.abs() / 100).clamp(0.0, 1.0);
    double facteurCouleurY = (_rotationCameraY.abs() / 100).clamp(0.0, 1.0);
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
                          _deplacementPersonnageX = x; // Mise à jour du déplacement du personnage
                          _deplacementPersonnageY = y;
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
                      // Mise à jour de la rotation de la caméra
                      _rotationCameraX += details.delta.dx;
                      _rotationCameraY += details.delta.dy;
                      // Limiter les valeurs pour éviter une couleur trop folle
                      _rotationCameraX = _rotationCameraX.clamp(-100.0, 100.0);
                      _rotationCameraY = _rotationCameraY.clamp(-100.0, 100.0);
                    });
                  },
                  child: Container(
                    color: couleurFondCamera, // Utilise la couleur calculée
                    // Le contenu de la scène de jeu irait ici
                    child: Center(
                      child: Text(
                        'Caméra: X:${_rotationCameraX.toInt()}, Y:${_rotationCameraY.toInt()}',
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
        // Le localPosition est relatif au GestureDetector.
        // On veut le positionner par rapport au centre de la base.
        // Donc, on doit ajuster la position du stick.
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
          // details.localPosition est la position par rapport au GestureDetector.
          // Pour un joystick "fixe" où le stick bouge à l'intérieur d'une base,
          // on calcule le déplacement du doigt par rapport au centre de la base du joystick.

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
