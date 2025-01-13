import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String authorId;
  final String content;
  final Timestamp timestamp;
  final String? authorName;
  final String? imageUrl; // Agregar esta propiedad

  Post({
    required this.postId,
    required this.authorId,
    required this.content,
    required this.timestamp,
    this.authorName,
    this.imageUrl, // Inicializarla aquí también
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      postId: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      authorName: data['authorName'],
      imageUrl: data['imageUrl'], // Asignar el valor aquí
    );
  }
}
