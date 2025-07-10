// ... imports remain unchanged
import 'dart:io';
import 'package:flutter/material.dart';
import 'add_book_page.dart';
import 'book_details_page.dart';
import 'entry_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> books = [];
  List<Map<String, String>> filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBooks);
  }

  void addBook(Map<String, String> newBook) {
    setState(() {
      books.add(newBook);
      _filterBooks();
    });
  }

  void updateBook(Map<String, String> oldBook, Map<String, String> updatedBook) {
    setState(() {
      final index = books.indexOf(oldBook);
      if (index != -1) {
        books[index] = updatedBook;
        _filterBooks();
      }
    });
  }

  void deleteBook(Map<String, String> bookToDelete) {
    setState(() {
      books.remove(bookToDelete);
      _filterBooks();
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        final title = book['title']?.toLowerCase() ?? '';
        final genre = book['genre'] ?? 'Other';
        final matchesTitle = title.contains(query);
        final matchesGenre = _selectedGenre == 'All' || genre == _selectedGenre;
        return matchesTitle && matchesGenre;
      }).toList();
    });
  }

  List<String> _getGenres() {
    final genres = books.map((b) => b['genre'] ?? 'Other').toSet().toList();

    // Always include 'Fiction' and 'Non-fiction'
    if (!genres.contains('Fiction')) genres.add('Fiction');
    if (!genres.contains('Non-fiction')) genres.add('Non-fiction');
    if (!genres.contains('Romance')) genres.add('Romance');

    genres.sort();
    return genres;
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genres = ['All', ..._getGenres()];

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 My Book List"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EntryScreen()),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by title...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  final isSelected = _selectedGenre == genre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedGenre = genre;
                          _filterBooks();
                        });
                      },
                      selectedColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredBooks.isEmpty
                  ? const Center(child: Text("No matching books found.", style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  final imagePath = book['imagePath'];
                  final hasImage = imagePath != null && imagePath.isNotEmpty;

                  return GestureDetector(
                    onTap: () async {
                      final updatedBook = await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailsPage(
                            book: book,
                            onBookEdited: (updatedBook) => updateBook(book, updatedBook),
                            onBookDeleted: () => deleteBook(book),
                          ),
                        ),
                      );
                      if (updatedBook != null) updateBook(book, updatedBook);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: hasImage
                                ? Image.file(File(imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover)
                                : Container(
                              height: 180,
                              color: Colors.deepPurple.shade100,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.deepPurple),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text (book ['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(book['author'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                                Text(book['year'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newBook = await Navigator.push<Map<String, String>>(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          );
          if (newBook != null) addBook(newBook);
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
      ),
    );
  }
}
