import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/widgets/app_inputfield.dart';
import 'package:routefixer/services/report_service.dart';

class AddDetailsPage extends StatefulWidget {
  final File imageFile;
  final String gps;
  final String time;
  final String firebaseUid; // 🔥 Added Firebase UID here

  const AddDetailsPage({
    super.key,
    required this.imageFile,
    required this.gps,
    required this.time,
    required this.firebaseUid,
  });

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ReportService _reportService = ReportService();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 🔥 Updated to send data + image to Django API
  Future<void> _saveDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descController.text.trim();

      debugPrint("Uploading report...");

      final response = await _reportService.sendReport(
        firebaseUid: widget.firebaseUid,
        imageFile: widget.imageFile,
        title: title,
        description: description,
        gps: widget.gps,
        time: widget.time,
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report sent successfully!")),
        );

        context.pop({
          "title": title,
          "description": description,
          "time": widget.time,
          "gps": widget.gps,
          "imagePath": widget.imageFile.path,
        });

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.statusCode}")),
        );
      }
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
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 16),

              AppInputField(
                controller: _descController,
                label: "Description",
                maxlines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Enter a description"
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveDetails,
                icon: const Icon(Icons.upload),
                label: const Text("Submit Report"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
