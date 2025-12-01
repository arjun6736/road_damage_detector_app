import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/services/cameraservice.dart';
import 'package:routefixer/services/report_service.dart'; // <-- Import
import 'package:shared_preferences/shared_preferences.dart';

class Repoartscreen extends StatefulWidget {
  const Repoartscreen({super.key});

  @override
  State<Repoartscreen> createState() => _RepoartscreenState();
}

class _RepoartscreenState extends State<Repoartscreen> {
  List<dynamic> reports = [];
  bool loading = true;
  String? firebaseUid;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ⬇ Load firebase_uid and fetch reports
  Future<void> loadUser() async {
    // final prefs = await SharedPreferences.getInstance();
    // firebaseUid = prefs.getString("firebase_uid");
    firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    print("Firebase UID => $firebaseUid");
    print(firebaseUid);
    if (firebaseUid == null) {
      setState(() => loading = false);
      return;
    }

    await fetchReports();
  }

  // ⬇ Call API using ReportService
  Future<void> fetchReports() async {
    try {
      final data = await ReportService().getReports(firebaseUid!);
      print(data);
      setState(() {
        reports = data;
        loading = false;
      });
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() => loading = false);
    }
  }

  // ⬇ Popup Details
  void _showReportDetails(BuildContext context, dynamic report) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      report["image_url"],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    report["damage_type"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    report["description"] ?? "No description available",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 6),
                      Text((report["timestamp"] ?? "").toString()),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${report["latitude"] ?? 0}, ${report["longitude"] ?? 0}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.flag, size: 18),
                      const SizedBox(width: 6),
                      Text("Status: ${report['status']}"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text("Close"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------- UI BUILD -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), centerTitle: true),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
          ? const Center(child: Text("No Reports Found"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return GestureDetector(
                  onTap: () => _showReportDetails(context, report),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
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
                      children: [
                        // ---------- TITLE + STATUS ON SAME ROW ----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                report["damage_type"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Status badge inside the box
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: report["status"] == "Pending"
                                    ? Colors.orange
                                    : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report["status"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          report["description"] ?? "No description available",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final controller = CameraService().controller;
          if (controller != null && controller.value.isInitialized) {
            context.push('/capture', extra: controller);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Camera not ready")));
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
