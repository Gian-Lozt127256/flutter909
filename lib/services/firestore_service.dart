import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener detalles de una publicación específica
  Stream<Post> getPostById(String postId) {
    return _db.collection('posts').doc(postId).snapshots().map((snapshot) {
      return Post.fromFirestore(snapshot);
    });
  }

  // Obtener lista de comentarios de una publicación
  Stream<List<Comment>> getComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  // Agregar un comentario a una publicación
  Future<void> addComment(
    String postId,
    String commenterName,
    String commenterEmail,
    String content,
  ) async {
    final commentRef =
        _db.collection('posts').doc(postId).collection('comments').doc();
    await commentRef.set({
      'commenterName': commenterName,
      'commenterEmail': commenterEmail,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });
  }

  // Alternar reacciones en comentarios
  Future<void> toggleSingleCommentReaction(String postId, String commentId,
      String userId, String reactionType) async {
    final commentRef = _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);
    final commentSnapshot = await commentRef.get();

    if (commentSnapshot.exists) {
      final commentData = commentSnapshot.data() as Map<String, dynamic>;
      final currentReactions =
          commentData['reactions'] as Map<String, dynamic>? ?? {};

      if (currentReactions[reactionType] is Map<String, dynamic>) {
        if (currentReactions[reactionType][userId] == true) {
          currentReactions[reactionType].remove(userId);
        } else {
          currentReactions[reactionType][userId] = true;
        }
      } else {
        currentReactions[reactionType] = {userId: true};
      }

      await commentRef.update({
        'reactions': currentReactions,
      });
    }
  }

  // Actualizar reacción en una publicación
  Future<void> updateReaction(
      String postId, String userId, String reactionType) async {
    final postRef = _db.collection('posts').doc(postId);
    final postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      final postData = postSnapshot.data() as Map<String, dynamic>;
      final currentReactions =
          postData['reactions'] as Map<String, dynamic>? ?? {};

      currentReactions.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey(userId)) {
          value.remove(userId);
        }
      });

      currentReactions[reactionType] = {
        ...(currentReactions[reactionType] as Map<String, dynamic>? ?? {}),
        userId: true,
      };

      await postRef.update({
        'reactions': currentReactions,
      });
    }
  }

  // Obtener el nombre de usuario
  Future<String?> getUserName(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc['name'];
    }
    return null;
  }

  // Eliminar un comentario
  Future<void> deleteComment(String postId, String commentId) async {
    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // Eliminar una publicación
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  // Guardar una publicación en el perfil de un usuario
  Future<void> savePostToProfile(String userId, String postId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'savedPosts': FieldValue.arrayUnion([postId])
    });
  }

  // Remover una publicación del perfil de un usuario
  Future<void> removePostFromProfile(String userId, String postId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'savedPosts': FieldValue.arrayRemove([postId])
    });
  }

  // Inicializar el documento del usuario si no existe
  Future<void> initializeUser(String userId) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'savedPosts': [],
      });
    }
  }
}
