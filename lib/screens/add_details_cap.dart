import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/services/report_service.dart';
import 'package:routefixer/widgets/app_inputfield.dart';

class AddDetailsPage extends StatefulWidget {
  final File imageFile;
  final String gps;
  final String time;
  final String firebaseUid;

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

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      // sendReport should return a http.Response-like object
      final response = await _reportService
          .sendReport(
            firebaseUid: widget.firebaseUid,
            imageFile: widget.imageFile,
            title: title,
            description: description,
            gps: widget.gps,
            time: widget.time,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report sent successfully!')),
          );
        }

        // small delay so user sees the success message
        await Future.delayed(const Duration(milliseconds: 500));

        // return success result to previous route, then pop one more level (capture)
        context.pop({
          'status': 'success',
          'title': title,
          'description': description,
          'time': widget.time,
          'gps': widget.gps,
          'imagePath': widget.imageFile.path,
        });
        context.pop();
      } else {
        final msg = 'Upload failed: ${response.statusCode}';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }

        await Future.delayed(const Duration(milliseconds: 500));

        context.pop({'status': 'error', 'message': msg});
        context.pop();
      }
    } on TimeoutException {
      const msg =
          'Request timed out. Please check your connection and try again.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(msg)));
      }
      // return timeout result
      context.pop({'status': 'timeout', 'message': msg});
      context.pop();
    } catch (e) {
      final msg = 'Error: $e';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      context.pop({'status': 'error', 'message': msg});
      context.pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Details')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text('Time: ${widget.time}'),
              Text('GPS: ${widget.gps}'),
              const SizedBox(height: 16),
              AppInputField(
                controller: _titleController,
                label: 'Title',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              AppInputField(
                controller: _descController,
                label: 'Description',
                maxlines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _saveDetails,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(_isSubmitting ? 'Uploading...' : 'Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
