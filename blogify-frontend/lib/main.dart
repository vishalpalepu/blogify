// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/blog_detail_screen.dart';
import 'screens/add_blog_screen.dart';

void main() {
  runApp(BlogifyApp());
}

class BlogifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogify',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/addBlog': (context) => AddBlogScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/blog/')) {
          final blogId = settings.name!.replaceFirst('/blog/', '');
          return MaterialPageRoute(
            builder: (context) => BlogDetailScreen(blogId: blogId),
          );
        }
        return null;
      },
    );
  }
}
