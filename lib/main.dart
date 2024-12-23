// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LibraryScreen(),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _fetchBooks() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'root',
      password: '',
      db: 'library_db',
    ));

    var results = await conn.query('SELECT id, title, author FROM books');
    setState(() {
      _books = results
          .map((row) => {
                'id': row[0],
                'title': row[1],
                'author': row[2],
              })
          .toList();
      _filteredBooks = _books;
    });

    await conn.close();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        final title = book['title'].toString().toLowerCase();
        final author = book['author'].toString().toLowerCase();
        return title.contains(query) || author.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBooks,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Title or Author',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(
                    child: Text(
                      'No books found!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredBooks.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Text(
                            book['title'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          book['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Author: ${book['author']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
