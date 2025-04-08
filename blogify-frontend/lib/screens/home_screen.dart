// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _blogs = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    try {
      final blogs = await ApiService.getBlogs();
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToAddBlog() {
    Navigator.pushNamed(context, '/addBlog').then((_) {
      _fetchBlogs();
    });
  }

  void _navigateToDetail(String blogId) {
    Navigator.pushNamed(context, '/blog/$blogId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _navigateToAddBlog),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : ListView.builder(
                itemCount: _blogs.length,
                itemBuilder: (context, index) {
                  final blog = _blogs[index];
                  return ListTile(
                    title: Text(blog['title'] ?? ""),
                    subtitle: Text(
                      blog['body'] != null
                          ? blog['body'].toString().substring(
                            0,
                            blog['body'].toString().length > 50
                                ? 50
                                : blog['body'].toString().length,
                          )
                          : "",
                    ),
                    onTap: () => _navigateToDetail(blog['_id']),
                  );
                },
              ),
    );
  }
}
