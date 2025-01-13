class User {
  String id;
  String name;
  String email;
  List<String> savedPosts;
  bool notificationsEnabled;
  bool emailNotificationsEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.savedPosts = const [],
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
  });

  // Método para crear un User desde un Map
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      savedPosts: List<String>.from(data['savedPosts'] ?? []),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
    );
  }

  // Método para convertir User a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'savedPosts': savedPosts,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
    };
  }

  // Método para agregar un post a savedPosts
  void addSavedPost(String postId) {
    if (!savedPosts.contains(postId)) {
      savedPosts.add(postId);
    }
  }

  // Método para eliminar un post de savedPosts
  void removeSavedPost(String postId) {
    savedPosts.remove(postId);
  }

  // Método para actualizar las preferencias de notificaciones en la app
  void setNotificationsEnabled(bool isEnabled) {
    notificationsEnabled = isEnabled;
  }

  // Método para actualizar las preferencias de notificaciones por correo
  void setEmailNotificationsEnabled(bool isEnabled) {
    emailNotificationsEnabled = isEnabled;
  }
}
