// lib/screens/add_blog_screen.dart

import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddBlogScreen extends StatefulWidget {
  @override
  _AddBlogScreenState createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  /// For mobile (Android/iOS), we store a [File].
  File? _imageFile;

  /// For web, we store the bytes of the picked image.
  Uint8List? _webImage;

  final ImagePicker _picker = ImagePicker();
  String _error = '';

  /// Picks an image from the gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          // Running on Web: read image as bytes
          final imageBytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = imageBytes;
            _imageFile = null; // Not used on web
          });
        } else {
          // Running on Mobile or Desktop: store a File
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImage = null; // Not used on mobile
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  /// Submit the blog to your backend
  Future<void> _submitBlog() async {
    try {
      // If you want to handle file uploads on mobile only:
      //   pass _imageFile to ApiService
      // If you also want to handle web uploads:
      //   you'll need a separate method or a different approach in ApiService
      await ApiService.addBlog(
        _titleController.text,
        _bodyController.text,
        kIsWeb ? null : _imageFile, // Currently null on web
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  /// Returns a widget that displays the chosen image
  Widget _buildImagePreview() {
    if (kIsWeb) {
      // Web preview using Image.memory
      if (_webImage != null) {
        return Image.memory(_webImage!);
      } else {
        return Text('No image selected');
      }
    } else {
      // Mobile preview using Image.file
      if (_imageFile != null) {
        return Image.file(_imageFile!);
      } else {
        return Text('No image selected');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Blog')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: TextStyle(color: Colors.red),
                ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bodyController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Body'),
              ),
              SizedBox(height: 10),
              // Image preview
              _buildImagePreview(),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitBlog,
                child: Text('Submit Blog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
