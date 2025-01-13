import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId;

  const CreatePostScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  Uint8List? _webImage;
  bool _isUploading = false;
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;

  // Función para seleccionar una imagen desde el navegador (solo web)
  void _pickImage() async {
    if (kIsWeb) {
      // Rest of the code...
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final file = uploadInput.files!.first;
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _webImage = reader.result as Uint8List?;
          });
        });
      });
    }
  }

  // Función para eliminar la imagen seleccionada
  void _removeImage() {
    setState(() {
      _webImage = null;
    });
  }

  // Función para subir la publicación con imagen a Firestore y Firebase Storage
  Future<void> _uploadPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, escribe algo en la publicación")),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una categoría")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Usuario no autenticado")),
        );
        return;
      }

      // Obtener el nombre del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final authorName = userDoc['name'] ?? 'Autor desconocido';

      String? imageUrl;
      if (_webImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putData(_webImage!);
        imageUrl = await ref.getDownloadURL(); // Obtener URL de descarga
      }

      // Guardar los datos de la publicación en Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'authorName': authorName,
        'content': _contentController.text,
        'imageUrl': imageUrl ?? '', // Guardar URL o vacío si no hay imagen
        'category': _selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Publicación creada exitosamente")),
      );

      _contentController.clear();
      setState(() {
        _webImage = null;
        _selectedCategory = null;
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error al subir la publicación: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear la publicación: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 100, 99, 99), // Color de fondo como en el LoginScreen
      appBar: AppBar(
        title: Text("Crear Publicación"),
        backgroundColor:
            const Color.fromARGB(255, 124, 235, 128), // Color de la AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isUploading) CircularProgressIndicator(),
              if (_webImage != null)
                Column(
                  children: [
                    Image.memory(_webImage!, height: 150),
                    SizedBox(height: 10),
                    TextButton.icon(
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text("Eliminar Imagen"),
                      onPressed: _removeImage,
                    ),
                  ],
                )
              else
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Seleccionar Imagen"),
                  onPressed: _pickImage,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, // Color de fondo del botón
                    side: BorderSide(color: Colors.green), // Color del borde
                  ),
                ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "Escribe algo...",
                    labelStyle: TextStyle(
                        color: Colors.white), // Color del texto del label
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  maxLines: 5,
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: 'becas',
                    child: Text('Becas'),
                  ),
                  DropdownMenuItem(
                    value: 'workshop',
                    child: Text('Workshop'),
                  ),
                  DropdownMenuItem(
                    value: 'seminario',
                    child: Text('Seminario'),
                  ),
                  DropdownMenuItem(
                    value: 'cursos',
                    child: Text('Cursos'),
                  ),
                  DropdownMenuItem(
                    value: 'evento',
                    child: Text('Evento'),
                  ),
                  DropdownMenuItem(
                    value: 'compartir',
                    child: Text('Compartir'),
                  ),
                  DropdownMenuItem(
                    value: 'otros',
                    child: Text('Otros'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(
                      color: Colors.white), // Color del texto del label
                  border: OutlineInputBorder(),
                ),
                dropdownColor: Colors.green, // Color del menú desplegable
                style: TextStyle(color: Colors.white), // Color del texto
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 124, 235, 128), // Color del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Publicar",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black), // Color del texto del botón
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
