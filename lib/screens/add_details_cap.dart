import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/widgets/app_inputfield.dart';

class AddDetailsPage extends StatefulWidget {
  final File imageFile;
  final String gps;
  final String time;

  const AddDetailsPage({
    super.key,
    required this.imageFile,
    required this.gps,
    required this.time,
  });

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descController.text.trim();

      // 🔹 Here you can save to DB or send API request
      debugPrint("Saving details:");
      debugPrint("Title: $title");
      debugPrint("Description: $description");
      debugPrint("Time: ${widget.time}");
      debugPrint("GPS: ${widget.gps}");
      debugPrint("Image path: ${widget.imageFile.path}");

      // Go back after saving
      context.pop({
        "title": title,
        "description": description,
        "time": widget.time,
        "gps": widget.gps,
        "imagePath": widget.imageFile.path,
      });
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Details")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text("Time: ${widget.time}"),
              Text("GPS: ${widget.gps}"),
              const SizedBox(height: 16),
              AppInputField(
                controller: _titleController,
                label: "Title",
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Enter a title"
                    : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: _descController,
                label: "Description",
                maxlines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Enter a description"
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveDetails,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
