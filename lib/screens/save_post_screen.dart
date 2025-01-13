import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class SavePostScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  SavePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Center(child: Text("Usuario no autenticado"));
    }

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 217, 217, 217), // Fondo gris oscuro
      appBar: AppBar(
        title: Text('Publicaciones Guardadas'),
        backgroundColor:
            const Color.fromARGB(255, 124, 235, 128), // Color del AppBar
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No hay publicaciones guardadas."));
          }

          final savedPosts =
              List<String>.from(snapshot.data!['savedPosts'] ?? []);

          if (savedPosts.isEmpty) {
            return Center(child: Text("No hay publicaciones guardadas."));
          }

          return ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(savedPosts[index])
                    .get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return ListTile(
                      title: Text("Publicación eliminada"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _firestoreService.removePostFromProfile(
                              user.uid, savedPosts[index]);
                        },
                      ),
                    );
                  }

                  final post =
                      postSnapshot.data!.data() as Map<String, dynamic>;
                  final content = post['content'] ?? 'Sin contenido';
                  final imageUrl = post['imageUrl'] as String? ?? '';

                  return Card(
                    margin: EdgeInsets.all(10),
                    color: const Color.fromARGB(
                        255, 246, 246, 246), // Fondo gris claro
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'Error al cargar la imagen',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            )
                          else
                            Text(
                              'No hay imagen disponible',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 60, 57, 57)),
                            ),
                          SizedBox(height: 10),
                          Text(
                            content,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: Icon(Icons.bookmark_remove),
                              onPressed: () {
                                _firestoreService.removePostFromProfile(
                                    user.uid, savedPosts[index]);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Publicación eliminada de guardados")),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
