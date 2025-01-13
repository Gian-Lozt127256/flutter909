import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatchTheBlocks extends StatefulWidget {
  const CatchTheBlocks({Key? key}) : super(key: key);

  @override
  _CatchTheBlocksState createState() => _CatchTheBlocksState();
}

class _CatchTheBlocksState extends State<CatchTheBlocks> {
  static const double blockSizeRatio =
      0.08; // Tamaño del bloque relativo a la pantalla
  static const double basketHeightRatio =
      0.03; // Altura de la canasta relativa a la pantalla
  static const double basketWidthRatio =
      0.25; // Ancho de la canasta relativo a la pantalla

  double basketX = 0.0; // Posición inicial de la canasta
  double blockX = Random().nextDouble() * 2 - 1; // Bloque en posición aleatoria
  double blockY = -1.0; // Bloque comienza fuera de la pantalla
  double blockFallSpeed = 0.005; // Velocidad inicial de caída
  int score = 0;
  bool isGameOver = false;

  late Timer gameLoopTimer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      score = 0;
      isGameOver = false;
      blockX = Random().nextDouble() * 2 - 1;
      blockY = -1.0;
      blockFallSpeed = 0.005;
    });

    gameLoopTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      if (isGameOver) return;

      blockY += blockFallSpeed;

      // Si el bloque llega al fondo sin ser atrapado
      if (blockY > 1.0) {
        _gameOver();
      }

      // Si el bloque es atrapado
      final screenWidth = MediaQuery.of(context).size.width;
      if ((blockY >= 0.9) &&
          (blockX > basketX - basketWidthRatio) &&
          (blockX < basketX + basketWidthRatio)) {
        score++;
        blockY = -1.0; // Reinicia la posición del bloque
        blockX = Random().nextDouble() * 2 - 1;
        blockFallSpeed += 0.001; // Incrementa la velocidad de caída
      }
    });
  }

  void _moveBasket(double direction) {
    setState(() {
      basketX += direction;
      if (basketX < -1.0) basketX = -1.0; // Límite izquierdo
      if (basketX > 1.0) basketX = 1.0; // Límite derecho
    });
  }

  void _gameOver() {
    setState(() {
      isGameOver = true;
      gameLoopTimer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final blockSize = screenWidth * blockSizeRatio;
    final basketHeight = screenHeight * basketHeightRatio;
    final basketWidth = screenWidth * basketWidthRatio;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Focus(
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _moveBasket(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _moveBasket(0.1);
            }
          }
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              _moveBasket(0.1); // Mover a la derecha
            } else {
              _moveBasket(-0.1); // Mover a la izquierda
            }
          },
          child: Stack(
            children: [
              // Bloque que cae
              AnimatedContainer(
                duration: Duration(milliseconds: 0),
                alignment: Alignment(blockX, blockY),
                child: Container(
                  width: blockSize,
                  height: blockSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Canasta
              AnimatedContainer(
                duration: Duration(milliseconds: 0),
                alignment: Alignment(basketX, 0.9),
                child: Container(
                  width: basketWidth,
                  height: basketHeight,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¡Juego Terminado!\nPuntaje final: $score',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child:
                              Text('Reiniciar', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameLoopTimer.cancel();
    super.dispose();
  }
}
