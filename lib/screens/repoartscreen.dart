import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routefixer/services/cameraservice.dart';
import 'package:routefixer/services/report_service.dart';

class Repoartscreen extends StatefulWidget {
  const Repoartscreen({super.key});

  @override
  State<Repoartscreen> createState() => _RepoartscreenState();
}

class _RepoartscreenState extends State<Repoartscreen> {
  List<dynamic> reports = [];
  bool loading = true;
  String? firebaseUid;

  String selectedStatus = "All";

  final List<String> statusFilters = [
    "All",
    "Pending",
    "Verified",
    "In Process",
    "Rejected",
    "Resolved",
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    firebaseUid = FirebaseAuth.instance.currentUser?.uid;
    if (firebaseUid == null) {
      setState(() => loading = false);
      return;
    }
    await fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      final data = await ReportService().getReports(firebaseUid!);
      setState(() {
        reports = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching reports: $e");
      setState(() => loading = false);
    }
  }

  // 🔁 Pull to refresh
  Future<void> _onRefresh() async {
    await fetchReports();
  }

  // 🔍 Filtered list
  List<dynamic> get filteredReports {
    if (selectedStatus == "All") return reports;
    return reports
        .where(
          (r) =>
              r["status"]?.toString().toLowerCase() ==
              selectedStatus.toLowerCase(),
        )
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "verified":
        return Colors.blue;
      case "in process":
        return Colors.purple;
      case "rejected":
        return Colors.red;
      case "resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showReportDetails(BuildContext context, dynamic report) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      report["image_url"] != null &&
                          report["image_url"].toString().isNotEmpty
                      ? Image.network(
                          report["image_url"],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 60,
                          ),
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
                Text(report["description"] ?? "No description available"),
                const SizedBox(height: 12),
                Text("Status: ${report["status"]}"),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), centerTitle: true),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔘 Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: statusFilters.map((status) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: selectedStatus == status,
                          onSelected: (_) {
                            setState(() => selectedStatus = status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // 🔁 Swipe to refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: filteredReports.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 200),
                              Center(child: Text("No Reports Found")),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(15),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = filteredReports[index];
                              return GestureDetector(
                                onTap: () =>
                                    _showReportDetails(context, report),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(
                                                report["status"],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                      Text(
                                        report["description"] ??
                                            "No description available",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          // 1. Access the 'cameras' list we just added
          final cams = CameraService().cameras;

          // 2. Check if it's not empty
          if (cams.isNotEmpty) {
            context.pushNamed("capture", extra: cams.first);
          } else {
            // Fallback: If list is empty, try fetching them dynamically (just in case main.dart didn't load them)
            availableCameras().then((fetchedCams) {
              if (fetchedCams.isNotEmpty) {
                CameraService().setCameras(fetchedCams);
                context.pushNamed("capture", extra: fetchedCams.first);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No camera found on this device"),
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }
}
