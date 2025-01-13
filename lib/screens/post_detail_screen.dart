import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  PostDetailScreen({super.key, required this.postId, required this.userId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    _userName = await widget._firestoreService.getUserName(widget.userId);
    setState(() {});
  }

  void _toggleCommentReaction(String commentId, String reactionType) async {
    await widget._firestoreService.toggleSingleCommentReaction(
      widget.postId,
      commentId,
      widget.userId,
      reactionType,
    );
  }

  void _deleteComment(String commentId) async {
    await widget._firestoreService.deleteComment(widget.postId, commentId);
  }

  void _deletePost(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Eliminar publicación"),
        content:
            Text("¿Estás seguro de que quieres eliminar esta publicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget._firestoreService.deletePost(widget.postId);
      Navigator.of(context)
          .pop(); // Regresa a la pantalla anterior después de eliminar
    }
  }

  void _savePost(BuildContext context) async {
    await widget._firestoreService
        .savePostToProfile(widget.userId, widget.postId);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Publicación guardada!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Fondo transparente para usar la imagen
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 111, 219, 115),
        title: Text("Detalles de la publicación"),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () => _savePost(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deletePost(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/fondo.jpg', // Asegúrate de tener la imagen en la carpeta 'assets'
              fit: BoxFit.cover,
            ),
          ),
          StreamBuilder<Post>(
            stream: widget._firestoreService.getPostById(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return Center(child: Text("No se pudo cargar la publicación."));
              }

              final post = snapshot.data!;
              final formattedTime = DateFormat('dd MMM yyyy, hh:mm a')
                  .format(post.timestamp.toDate());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      post.authorName ?? "Anónimo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text("Publicado el $formattedTime"),
                  ),
                  if (post.imageUrl != null)
                    Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(post.content),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Comentarios",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Comment>>(
                      stream:
                          widget._firestoreService.getComments(widget.postId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text("No hay comentarios."));
                        }

                        final comments = snapshot.data!;

                        return ListView.builder(
                          itemCount: comments.length,
                          reverse:
                              true, // Para que los comentarios nuevos aparezcan al final
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final commentTime =
                                DateFormat('dd MMM yyyy, hh:mm a')
                                    .format(comment.timestamp.toDate());

                            return ListTile(
                              title: Text(
                                comment.commenterName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment.content),
                                  Text(
                                    commentTime,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  Row(
                                    children: [
                                      _reactionIconButton(
                                        icon: Icons.thumb_up,
                                        color: const Color.fromARGB(
                                            255, 40, 116, 255), // Azul
                                        reactionType: 'like',
                                        comment: comment,
                                      ),
                                      _reactionIconButton(
                                        icon: Icons.favorite,
                                        color: const Color.fromARGB(
                                            255, 255, 0, 0), // Rojo
                                        reactionType: 'heart',
                                        comment: comment,
                                      ),
                                      _reactionIconButton(
                                        icon: Icons.emoji_emotions,
                                        color: const Color.fromARGB(
                                            255, 255, 221, 51), // Amarillo
                                        reactionType: 'sonrisa',
                                        comment: comment,
                                      ),
                                      _reactionIconButton(
                                        icon: Icons.approval,
                                        color: const Color.fromARGB(
                                            255, 40, 167, 69), // Verde
                                        reactionType: 'aplauso',
                                        comment: comment,
                                      ),
                                      if (comment.commenterName == _userName)
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteComment(comment.id),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: "Escribe un comentario con emojis...",
                              hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            if (_commentController.text.isNotEmpty) {
                              await widget._firestoreService.addComment(
                                widget.postId,
                                _userName ?? "Anónimo",
                                "correo@ejemplo.com", // Ajusta este campo para obtener el correo real
                                _commentController.text,
                              );
                              _commentController
                                  .clear(); // Limpia el campo de texto después de enviar el comentario
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _reactionIconButton({
    required IconData icon,
    required Color color,
    required String reactionType,
    required Comment comment,
  }) {
    // Verificación y obtención del contador de reacciones
    final dynamic reaction = comment.reactions[reactionType];
    int reactionCount = 0;

    if (reaction is int) {
      reactionCount = reaction;
    } else if (reaction is Map<String, dynamic>) {
      reactionCount = reaction.values.where((v) => v == true).length;
    } else {
      reactionCount = 0;
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(icon),
          color:
              reactionCount > 0 ? color : const Color.fromARGB(255, 34, 33, 33),
          onPressed: () => _toggleCommentReaction(comment.id, reactionType),
        ),
        Text('$reactionCount'),
      ],
    );
  }
}
