import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/main.dart';

class Repoartscreen extends StatelessWidget {
  const Repoartscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15), // 20 margin around
          child: Stack(
            children: [
              // Full-width card
              Container(
                width: double.infinity, // take full width
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Box Title",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This is a sample description that will be trimmed "
                      "if it overflows. This description is intentionally "
                      "long to test overflow.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              // Status badge (top right corner of the card)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Active",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating button at bottom
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(
            'capture',
            extra: cameras![0], // or whichever camera you want to use
          );
        },
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        child: Icon(Icons.add),
      ),
    );
  }
}
