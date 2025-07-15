import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/api_service.dart';

class AddBookPage extends StatefulWidget {
  final Map<String, dynamic>? initialBook;

  const AddBookPage({super.key, this.initialBook});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _genre = 'Other';
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    // Pre-fill form if editing
    final book = widget.initialBook;
    if (book != null) {
      _titleController.text = book['title'] ?? '';
      _authorController.text = book['author'] ?? '';
      _yearController.text = book['year'] ?? '';
      _descriptionController.text = book['description'] ?? '';
      _genre = book['genre'] ?? 'Other';
      _imagePath = book['imagePath'];
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Limit image size to reduce upload time
      maxHeight: 1024,
      imageQuality: 85, // Compress image to reduce file size
    );

    if (picked != null) {
      try {
        print('Image picked: ${picked.path}');
        final file = File(picked.path);
        print('File size: ${await file.length()} bytes');
        print('File exists: ${await file.exists()}');
        
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Uploading image...'),
                ],
              ),
              duration: Duration(seconds: 30), // Long duration for upload
            ),
          );
        }
        
        print('Uploading image to server...');
        final result = await ApiService.instance.uploadImage(file);
        print('Upload result: $result');
        
        setState(() {
          _imagePath = result['data']['url'];
        });
        print('Image path set to: $_imagePath');
        
        if (mounted) {
          // Clear the loading snackbar
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error uploading image: $e');
        if (mounted) {
          // Clear the loading snackbar
          ScaffoldMessenger.of(context).clearSnackBars();
          
          String errorMessage = 'Failed to upload image';
          
          if (e.toString().contains('timed out') || e.toString().contains('timeout')) {
            errorMessage = 'Upload timed out. Please check your internet connection and try again.';
          } else if (e.toString().contains('too large')) {
            errorMessage = 'Image file is too large. Please select a smaller image (max 5MB).';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection.';
          } else if (e.toString().contains('not an image')) {
            errorMessage = 'Please select a valid image file (JPEG, PNG, GIF, WebP).';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _pickImage(),
              ),
            ),
          );
        }
      }
    }
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      final book = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'year': _yearController.text.trim(),
        'description': _descriptionController.text.trim(),
        'genre': _genre,
        'imagePath': _imagePath ?? '',
      };
      Navigator.pop(context, book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialBook != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Book" : "Add Book"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Book Cover Picker (realistic book size)
              GestureDetector(
                onTap: _pickImage,
                child: _imagePath != null && _imagePath!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 180,
                    height: 277,
                    child: _imagePath!.startsWith('http')
                        ? Image.network(
                            _imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                              );
                            },
                          )
                        : _imagePath!.startsWith('/uploads/')
                            ? Image.network(
                                'http://192.168.193.200:5000$_imagePath',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  );
                                },
                              )
                            : Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                              ),
                  ),
                )
                    : Container(
                  width: 180,
                  height: 277,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              /// Author Field
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              /// Year Field
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Published Year',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              /// Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter a brief description of the book...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              /// Genre Dropdown
              DropdownButtonFormField<String>(
                value: _genre,
                decoration: InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Fiction', child: Text('Fiction')),
                  DropdownMenuItem(value: 'Non-fiction', child: Text('Non-fiction')),
                  DropdownMenuItem(value: 'Biography', child: Text('Biography')),
                  DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                  DropdownMenuItem(value: 'Science', child: Text('Science')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _genre = value);
                },
              ),

              const SizedBox(height: 30),

              /// Save Button
              ElevatedButton.icon(
                onPressed: _saveBook,
                icon: const Icon(Icons.check),
                label: Text(isEditing ? "Save Changes" : "Add Book"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
