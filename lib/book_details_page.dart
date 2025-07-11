import 'dart:io';
import 'package:flutter/material.dart';
import 'add_book_page.dart';

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> book;
  final Function(Map<String, dynamic>) onBookEdited;
  final VoidCallback onBookDeleted;

  const BookDetailsPage({
    super.key,
    required this.book,
    required this.onBookEdited,
    required this.onBookDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = book['imagePath'];
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Book"),
                  content: const Text("Are you sure you want to delete this book?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        onBookDeleted();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close details page
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Book Cover Image with border and shadow
            Container(
              width: 180,
              height: 277,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasImage
                    ? imagePath!.startsWith('http')
                        ? Image.network(
                            imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.deepPurple.shade50,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.broken_image, size: 60, color: Colors.deepPurple),
                                    SizedBox(height: 6),
                                    Text("No Cover Image", style: TextStyle(color: Colors.deepPurple)),
                                  ],
                                ),
                              );
                            },
                          )
                        : imagePath!.startsWith('/uploads/')
                            ? Image.network(
                                'http://192.168.193.186:8080$imagePath',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.deepPurple.shade50,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.broken_image, size: 60, color: Colors.deepPurple),
                                        SizedBox(height: 6),
                                        Text("No Cover Image", style: TextStyle(color: Colors.deepPurple)),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                              )
                    : Container(
                  color: Colors.deepPurple.shade50,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.broken_image, size: 60, color: Colors.deepPurple),
                      SizedBox(height: 6),
                      Text("No Cover Image", style: TextStyle(color: Colors.deepPurple)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Book Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    DetailRow(label: "Author", value: book['author'] ?? 'Unknown'),
                    const SizedBox(height: 12),
                    DetailRow(label: "Published Year", value: book['year'] ?? 'N/A'),
                    const SizedBox(height: 12),
                    DetailRow(label: "Genre", value: book['genre'] ?? 'Other'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// Edit Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.edit),
        label: const Text("Edit"),
        onPressed: () async {
          final updatedBook = await Navigator.push<Map<String, String>>(
            context,
            MaterialPageRoute(
              builder: (_) => AddBookPage(initialBook: book),
            ),
          );

          if (updatedBook != null) {
            onBookEdited(updatedBook);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
