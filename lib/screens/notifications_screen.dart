import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool notificationsEnabled = true;
  bool emailNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _subscribeToPostNotifications();
  }

  Future<void> _loadNotificationSettings() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (userDoc.exists) {
      setState(() {
        notificationsEnabled = userDoc['notificationsEnabled'] ?? true;
        emailNotificationsEnabled =
            userDoc['emailNotificationsEnabled'] ?? true;
      });
    }
  }

  Future<void> _updateNotificationSettings() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
    });
  }

  Future<void> _clearReadNotifications() async {
    final readNotifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: widget.userId)
        .where('read', isEqualTo: true)
        .get();

    for (var doc in readNotifications.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notificaciones leídas eliminadas")),
    );
  }

  Future<void> _subscribeToPostNotifications() async {
    FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final postData = docChange.doc.data() as Map<String, dynamic>;
          final postTitle = postData['title'];
          final postCategory = postData['category'];
          final timestamp = postData['timestamp'] as Timestamp;

          _showPostNotification(postTitle, postCategory, timestamp);
        }
      }
    });
  }

  Future<void> _showPostNotification(
      String postTitle, String postCategory, Timestamp timestamp) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': widget.userId,
      'content':
          'Nueva publicación: "$postTitle" en la categoría "$postCategory"',
      'timestamp': timestamp,
      'read': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Nueva publicación: "$postTitle" en la categoría "$postCategory"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 160, 247, 166), // Fondo gris oscuro
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearReadNotifications,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tienes notificaciones."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData =
                  notifications[index].data() as Map<String, dynamic>;
              final content = notificationData['content'] ?? 'Notificación';
              final timestamp = notificationData['timestamp'] as Timestamp;
              final formattedTime =
                  DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
              final isRead = notificationData['read'] ?? false;

              return ListTile(
                title: Text(content),
                subtitle: Text(formattedTime),
                trailing: Icon(
                  isRead ? Icons.notifications : Icons.notifications_active,
                  color: isRead
                      ? const Color.fromARGB(246, 37, 37, 37)
                      : const Color.fromARGB(255, 142, 252, 173),
                ),
                onTap: () async {
                  final notificationId = notifications[index].id;
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notificationId)
                      .update({'read': true});
                  // Navegar a la nueva publicación si es necesario
                },
              );
            },
          );
        },
      ),
    );
  }
}
