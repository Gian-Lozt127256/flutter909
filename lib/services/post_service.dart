import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear una nueva publicación y enviar notificación a los seguidores
  Future<void> createPost(String userId, String content) async {
    final postsRef = _db.collection('posts');
    final newPost = await postsRef.add({
      'userId': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });

    // Crear notificación para todos los seguidores del usuario que creó la publicación
    await _createNotificationForNewPost(newPost.id, content, userId);
  }

  // Crear notificación para todos los seguidores de una publicación
  Future<void> _createNotificationForNewPost(
      String postId, String content, String userId) async {
    try {
      // Obtener todos los usuarios
      final usersSnapshot = await _db.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final followerId = userDoc.id;

        // Evitar enviar la notificación al usuario que creó la publicación
        if (followerId == userId) continue;

        final notificationsEnabled =
            userDoc.data()['notificationsEnabled'] ?? true;
        final emailNotificationsEnabled =
            userDoc.data()['emailNotificationsEnabled'] ?? false;

        // Crear la notificación en Firestore
        if (notificationsEnabled) {
          await _db.collection('notifications').add({
            'userId': followerId,
            'content': 'Nueva publicación: $content',
            'postId': postId,
            'read': false,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        // Si el usuario tiene habilitadas las notificaciones por correo, envía un correo electrónico
        if (emailNotificationsEnabled) {
          final email = userDoc.data()['email'];
          if (email != null) {
            await _sendEmailNotification(email, content);
          }
        }
      }
    } catch (e) {
      print("Error creando notificación: $e");
    }
  }

  Future<void> _sendEmailNotification(String email, String content) async {
    // Implementa tu servicio de envío de correos aquí
    // Ejemplo de cómo enviar un correo electrónico usando un servicio de correo como SendGrid, SMTP, o Firebase Functions
    print("Enviar correo a $email sobre nueva publicación: $content");

    // Aquí tendrías que usar un servicio externo (como SendGrid) o Firebase Functions
    // para enviar el correo electrónico de forma efectiva.
  }

  // Obtener lista de publicaciones ordenadas por fecha
  Stream<List<Map<String, dynamic>>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Dar 'me gusta' o reaccionar a una publicación
  Future<void> likePost(String postId, String userId) async {
    final postRef = _db.collection('posts').doc(postId);

    await postRef.update({
      'reactions.likes': FieldValue.arrayUnion([userId])
    });
  }

  // Guardar una publicación en el perfil del usuario
  Future<void> savePostToProfile(String userId, String postId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'savedPosts': FieldValue.arrayUnion([postId])
    });
  }

  // Quitar la publicación guardada del perfil del usuario
  Future<void> removePostFromProfile(String userId, String postId) async {
    final userRef = _db.collection('users').doc(userId);
    await userRef.update({
      'savedPosts': FieldValue.arrayRemove([postId])
    });
  }

  // Agregar un comentario a una publicación
  Future<void> addComment(String postId, String userId, String content) async {
    final postRef = _db.collection('posts').doc(postId);

    final comment = {
      'userId': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await postRef.collection('comments').add(comment);
  }

  // Eliminar una publicación y sus notificaciones asociadas
  Future<void> deletePost(String postId) async {
    final postRef = _db.collection('posts').doc(postId);
    await postRef.delete();

    // Remover la publicación de las notificaciones
    await _removePostFromNotifications(postId);
  }

  // Remover una publicación de todas las notificaciones de un usuario
  Future<void> _removePostFromNotifications(String postId) async {
    final notifications = await _db
        .collection('notifications')
        .where('postId', isEqualTo: postId)
        .get();

    for (var notification in notifications.docs) {
      await notification.reference.delete();
    }
  }
}
