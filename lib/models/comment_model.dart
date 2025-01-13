import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String commenterName;
  final String commenterEmail;
  final Timestamp timestamp;
  final String postId;
  final Map<String, dynamic> reactions;

  Comment({
    required this.id,
    required this.content,
    required this.commenterName,
    required this.commenterEmail,
    required this.timestamp,
    required this.postId,
    required this.reactions,
  });

  // Método para obtener un comentario desde un documento de Firestore
  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      content: data['content'] ?? '',
      commenterName: data['commenterName'] ?? 'Anónimo',
      commenterEmail: data['commenterEmail'] ?? 'Correo no disponible',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      postId: data['postId'] ?? '',
      reactions: Map<String, dynamic>.from(data['reactions'] ??
          {
            'like': 0,
            'heart': 0,
            'sonrisa': 0,
            'aplauso': 0,
          }),
    );
  }

  // Método para convertir el comentario a un formato compatible con Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'commenterName': commenterName,
      'commenterEmail': commenterEmail,
      'timestamp': timestamp,
      'postId': postId,
      'reactions': reactions,
    };
  }
}
