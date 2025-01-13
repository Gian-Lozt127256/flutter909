import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'view_posts_screen.dart';
import 'save_post_screen.dart';
import 'notifications_screen.dart';
import 'juegos.dart'; // Importamos CatchTheBlocks

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Flutter Firebase Demo'),
        backgroundColor: const Color.fromARGB(255, 124, 235, 128),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/fondo1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Crear Publicación
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePostScreen(userId: userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 124, 235, 128),
                  foregroundColor: const Color.fromARGB(255, 20, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child:
                    Text('Crear Publicación', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 30),

              // Botón Ver Publicaciones
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewPostsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 111, 219, 115),
                  foregroundColor: const Color.fromARGB(255, 20, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child:
                    Text('Ver Publicaciones', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 30),

              // Botón Publicaciones Guardadas
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavePostScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 111, 219, 115),
                  foregroundColor: const Color.fromARGB(255, 20, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Publicaciones Guardadas',
                    style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 30),

              // Botón Notificaciones
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(userId: userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 111, 219, 115),
                  foregroundColor: const Color.fromARGB(255, 20, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Notificaciones', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 30),

              // Botón para el juego Catch the Falling Blocks
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CatchTheBlocks(), // Navegar al juego
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 120, 190, 250),
                  foregroundColor: const Color.fromARGB(255, 20, 19, 19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Jugar Catch the Blocks',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
