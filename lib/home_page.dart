import 'dart:io';
import 'package:flutter/material.dart';
import 'add_book_page.dart';
import 'book_details_page.dart';
import 'entry_screen.dart';
import 'services/api_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterBooks);
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      print('Testing API connection...');
      
      // First test the health endpoint
      try {
        final health = await ApiService.instance.healthCheck();
        print('Health check successful: $health');
      } catch (e) {
        print('Health check failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot connect to server. Make sure backend is running on port 3001.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      print('Loading books from API...');
      final booksData = await ApiService.instance.getBooks();
      print('Books loaded: ${booksData.length}');
      print('Books data: $booksData');
      
      setState(() {
        books = booksData;
        _filterBooks();
      });
      
      print('Filtered books: ${filteredBooks.length}');
    } catch (e) {
      print('Error loading books: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load books: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> addBook(Map<String, dynamic> newBook) async {
    try {
      final result = await ApiService.instance.createBook(
        title: newBook['title'] ?? '',
        author: newBook['author'] ?? '',
        year: newBook['year'],
        genre: newBook['genre'] ?? 'Other',
        imagePath: newBook['imagePath'],
      );
      
      setState(() {
        books.add(result['data']);
        _filterBooks();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add book: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateBook(Map<String, dynamic> oldBook, Map<String, dynamic> updatedBook) async {
    try {
      final result = await ApiService.instance.updateBook(
        id: oldBook['_id'] ?? '',
        title: updatedBook['title'] ?? '',
        author: updatedBook['author'] ?? '',
        year: updatedBook['year'],
        genre: updatedBook['genre'] ?? 'Other',
        imagePath: updatedBook['imagePath'],
      );
      
      setState(() {
        final index = books.indexOf(oldBook);
        if (index != -1) {
          books[index] = result['data'];
          _filterBooks();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update book: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteBook(Map<String, dynamic> bookToDelete) async {
    try {
      await ApiService.instance.deleteBook(bookToDelete['_id'] ?? '');
      setState(() {
        books.remove(bookToDelete);
        _filterBooks();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete book: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final genres = books.map((b) => (b['genre'] ?? 'Other').toString()).toSet().toList();

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.book, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                books.isEmpty 
                                    ? "No books found. Add your first book!" 
                                    : "No matching books found.",
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              if (books.isEmpty) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    final newBook = await Navigator.push<Map<String, dynamic>>(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AddBookPage()),
                                    );
                                    if (newBook != null) await addBook(newBook);
                                  },
                                  child: const Text("Add Your First Book"),
                                ),
                              ],
                            ],
                          ),
                        )
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
                      final updatedBook = await Navigator.push<Map<String, dynamic>>(
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
                                ? imagePath!.startsWith('http')
                                    ? Image.network(
                                        imagePath!,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 180,
                                            color: Colors.deepPurple.shade100,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 50, color: Colors.deepPurple),
                                            ),
                                          );
                                        },
                                      )
                                    : imagePath!.startsWith('/uploads/')
                                        ? Image.network(
                                            'http://192.168.193.186:8080$imagePath',
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                color: Colors.deepPurple.shade100,
                                                child: const Center(
                                                  child: Icon(Icons.broken_image, size: 50, color: Colors.deepPurple),
                                                ),
                                              );
                                            },
                                          )
                                        : Image.file(File(imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover)
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
          final newBook = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          );
          if (newBook != null) await addBook(newBook);
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
      ),
    );
  }
}
