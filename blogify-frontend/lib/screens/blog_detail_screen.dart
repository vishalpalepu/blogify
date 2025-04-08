// lib/screens/blog_detail_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;
  BlogDetailScreen({required this.blogId});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Map<String, dynamic>? _blogData;
  bool _isLoading = true;
  String _error = '';
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlog();
  }

  Future<void> _fetchBlog() async {
    try {
      final data = await ApiService.getBlog(widget.blogId);
      setState(() {
        _blogData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final content = _commentController.text;
    if (content.isEmpty) return;
    try {
      await ApiService.addComment(widget.blogId, content);
      _commentController.clear();
      _fetchBlog();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blog = _blogData?['blog'];
    final comments = _blogData?['comments'] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(blog != null ? blog['title'] : 'Blog Detail')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (blog != null) ...[
                          if (blog['coverImageURL'] != null &&
                              blog['coverImageURL'].isNotEmpty)
                            Image.network(
                              'http://your-backend-url.com${blog['coverImageURL']}',
                            ),
                          SizedBox(height: 10),
                          Text(
                            blog['title'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(blog['body']),
                          Divider(),
                        ],
                        Text('Comments', style: TextStyle(fontSize: 20)),
                        ...comments.map<Widget>(
                          (comment) => ListTile(
                            leading: comment['createdBy'] != null &&
                                    comment['createdBy']['profileImageURL'] !=
                                        null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      'http://your-backend-url.com${comment['createdBy']['profileImageURL']}',
                                    ),
                                  )
                                : CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              comment['createdBy']?['fullname'] ?? 'Anonymous',
                            ),
                            subtitle: Text(comment['content']),
                          ),
                        ),
                        TextField(
                          controller: _commentController,
                          decoration: InputDecoration(labelText: 'Add Comment'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _addComment,
                          child: Text('Submit Comment'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
