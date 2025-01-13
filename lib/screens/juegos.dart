import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class FlappyBlock extends StatefulWidget {
  @override
  _FlappyBlockState createState() => _FlappyBlockState();
}

class _FlappyBlockState extends State<FlappyBlock> {
  static const double gravity = 2.0;
  static const double jumpForce = -18.0; // Ajustado para mayor control
  static const double blockSize = 40.0;
  static const double obstacleWidth = 80.0;

  double blockY = 0.0;
  double velocity = 0.0;

  List<Obstacle> obstacles = [];
  double obstacleSpeed = 1.5; // Velocidad inicial ajustada
  int score = 0;
  bool isGameOver = false;
  bool isGameStarted = false;

  late Timer gameLoopTimer;

  void _startGame() {
    setState(() {
      blockY = 0.0;
      velocity = 0.0;
      score = 0;
      isGameOver = false;
      isGameStarted = true;
      obstacles = List.generate(3, (i) => Obstacle(300.0 + i * 200));
    });

    gameLoopTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      if (isGameOver) return;

      // Actualizar posición del bloque
      velocity += gravity;
      blockY += velocity * 0.016;

      // Limitar el bloque dentro de los límites de la pantalla
      if (blockY > 1.0 || blockY < -1.0) {
        _gameOver();
      }

      // Actualizar obstáculos
      for (var obstacle in obstacles) {
        obstacle.x -= obstacleSpeed;

        if (obstacle.x < -1.2) {
          obstacle.x = 1.2;
          obstacle.gapY = Random().nextDouble() * 0.6 - 0.3;
          score++;
          if (score % 5 == 0) {
            obstacleSpeed += 0.2; // Incrementar la velocidad cada 5 puntos
          }
        }

        // Detectar colisión
        if (obstacle.collidesWith(blockY, blockSize)) {
          _gameOver();
        }
      }
    });
  }

  void _jump() {
    if (isGameOver) {
      _startGame();
    } else {
      setState(() {
        velocity = jumpForce;
      });
    }
  }

  void _gameOver() {
    setState(() {
      isGameOver = true;
      gameLoopTimer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: isGameStarted
          ? GestureDetector(
              onTap: _jump,
              child: Stack(
                children: [
                  // Bloque del jugador
                  AnimatedContainer(
                    duration: Duration(milliseconds: 0),
                    alignment: Alignment(0.0, blockY),
                    child: Container(
                      width: blockSize,
                      height: blockSize,
                      color: Colors.red,
                    ),
                  ),

                  // Obstáculos
                  ...obstacles.map(
                    (obstacle) => ObstacleWidget(obstacle: obstacle),
                  ),

                  // Puntaje
                  Positioned(
                    top: 50.0,
                    left: 20.0,
                    child: Text(
                      'Puntaje: $score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Mensaje de fin de juego
                  if (isGameOver)
                    Center(
                      child: Text(
                        '¡Juego Terminado!\nToca para reiniciar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : _buildInstructions(),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¡Bienvenido a Flappy Block!',
            style: TextStyle(
              fontSize: 28.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Instrucciones:',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '1. Toca la pantalla para hacer que el bloque salte.\n'
            '2. Evita los obstáculos verdes.\n'
            '3. Gana puntos al pasar los obstáculos.\n'
            '4. Toca para comenzar.',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _startGame,
            child: Text(
              '¡Comenzar!',
              style: TextStyle(fontSize: 20.0),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoopTimer.cancel();
    super.dispose();
  }
}

class Obstacle {
  double x;
  double gapY;
  static const double gapHeight = 0.4;

  Obstacle(this.x) : gapY = Random().nextDouble() * 0.6 - 0.3;

  bool collidesWith(double blockY, double blockSize) {
    return (x < -0.05 && x > -0.15) &&
        (blockY < gapY - gapHeight / 2 || blockY > gapY + gapHeight / 2);
  }
}

class ObstacleWidget extends StatelessWidget {
  final Obstacle obstacle;

  const ObstacleWidget({Key? key, required this.obstacle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 0),
      alignment: Alignment(obstacle.x, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.0,
            height: MediaQuery.of(context).size.height *
                (0.5 + obstacle.gapY - Obstacle.gapHeight / 2),
            color: Colors.green,
          ),
          Container(
            width: 80.0,
            height: MediaQuery.of(context).size.height *
                (0.5 - obstacle.gapY - Obstacle.gapHeight / 2),
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
