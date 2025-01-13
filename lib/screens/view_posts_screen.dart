import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import '../screens/post_detail_screen.dart';
import '../services/firestore_service.dart';

class ViewPostsScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestoreService = FirestoreService();

  ViewPostsScreen({Key? key});

  void _deletePost(BuildContext context, String postId) async {
    if (postId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Publicación eliminada exitosamente")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar la publicación: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ID de la publicación no válido.")),
      );
    }
  }

  void _toggleReaction(
      String postId, String userId, String reactionType) async {
    if (postId.isNotEmpty) {
      await _firestoreService.updateReaction(postId, userId, reactionType);
    } else {
      print("Error: El postId está vacío.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 71, 65, 65), // Fondo gris oscuro
      appBar: AppBar(
        title: Text('Publicaciones'),
        backgroundColor:
            const Color.fromARGB(255, 105, 255, 105), // Color verde
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No hay publicaciones disponibles."));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>?;

              if (data == null) {
                return SizedBox(); // Si los datos son nulos, retorna un widget vacío
              }

              final content = data['content'] ?? 'Sin contenido';
              final imageUrl = data['imageUrl'] as String? ?? '';
              final reactions =
                  data['reactions'] as Map<String, dynamic>? ?? {};
              final timestamp = data['timestamp'] as Timestamp?;
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(timestamp.toDate())
                  : 'Fecha desconocida';
              final authorName = data['authorName'] ?? 'Desconocido';

              final isCurrentUserPost =
                  user != null && user.uid == data['authorId'];

              return GestureDetector(
                onTap: () {
                  if (user != null) {
                    if (post.id.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postId: post.id,
                            userId: user.uid,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Error: ID de la publicación no válido."),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Inicia sesión para ver detalles")),
                    );
                  }
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  color:
                      const Color.fromARGB(255, 241, 246, 241), // Color verde
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            authorName,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Publicado el $formattedDate",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(height: 10),
                        SelectableText.rich(
                          TextSpan(
                            children: _buildContentTextSpans(content),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _reactionIconButton(
                                  context: context,
                                  icon: Icons.thumb_up,
                                  color: Colors.blue,
                                  reactionType: 'like',
                                  postId: post.id,
                                  user: user,
                                  reactions: reactions,
                                ),
                                _reactionIconButton(
                                  context: context,
                                  icon: Icons.favorite,
                                  color: Colors.red,
                                  reactionType: 'heart',
                                  postId: post.id,
                                  user: user,
                                  reactions: reactions,
                                ),
                                _reactionIconButton(
                                  context: context,
                                  icon: Icons.emoji_emotions,
                                  color: Colors.yellow[700]!,
                                  reactionType: 'sonrisa',
                                  postId: post.id,
                                  user: user,
                                  reactions: reactions,
                                ),
                                _reactionIconButton(
                                  context: context,
                                  icon: Icons.approval,
                                  color: Colors.green,
                                  reactionType: 'aplauso',
                                  postId: post.id,
                                  user: user,
                                  reactions: reactions,
                                ),
                              ],
                            ),
                            if (isCurrentUserPost)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deletePost(context, post.id);
                                    },
                                    color: Colors.red,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.save),
                                    onPressed: () {
                                      // Implement save post functionality
                                    },
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _reactionIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String reactionType,
    required String postId,
    required User? user,
    required Map<String, dynamic> reactions,
  }) {
    int reactionCount = 0;

    final dynamic reaction = reactions[reactionType];
    if (reaction is int) {
      reactionCount = reaction;
    } else if (reaction is Map<String, dynamic>) {
      reactionCount = reaction.values.where((v) => v == true).length;
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(icon),
          color: reactionCount > 0 ? color : Colors.grey,
          onPressed: () {
            if (user != null) {
              if (postId.isNotEmpty) {
                _toggleReaction(postId, user.uid, reactionType);
              } else {
                print("Error: El postId está vacío.");
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Inicia sesión para reaccionar")),
              );
            }
          },
        ),
        Text('$reactionCount'),
      ],
    );
  }

  List<TextSpan> _buildContentTextSpans(String content) {
    final urlPattern = RegExp(r"(https?:\/\/[^\s]+)");
    final matches = urlPattern.allMatches(content);

    if (matches.isEmpty) {
      return [TextSpan(text: content)];
    }

    final List<TextSpan> textSpans = [];
    int previousEnd = 0;

    for (final match in matches) {
      final url = match.group(0);
      if (url != null) {
        final beforeText = content.substring(previousEnd, match.start);
        final urlText = content.substring(match.start, match.end);

        if (beforeText.isNotEmpty) {
          textSpans.add(TextSpan(text: beforeText));
        }

        textSpans.add(
          TextSpan(
            text: urlText,
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(url);
              },
          ),
        );

        previousEnd = match.end;
      }
    }

    final remainingText = content.substring(previousEnd);
    if (remainingText.isNotEmpty) {
      textSpans.add(TextSpan(text: remainingText));
    }

    return textSpans;
  }
}
