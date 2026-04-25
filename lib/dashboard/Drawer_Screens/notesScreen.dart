import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:school_management_system/controllers/notes_controller.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/notes_subscreens/image_screen.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/notes_subscreens/pdf_screen.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:school_management_system/utils/file_downloader.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';

class NotesScreen extends StatelessWidget {
  NotesScreen({super.key});

  final NotesController controller = Get.put(NotesController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      bottomNavigationBar: const AppFooter(),
      body: Padding(
        padding: EdgeInsets.all(isSmall ? 10 : 12), // ✅ responsive padding
        child: Column(
          children: [
            // 🔽 SUBJECT DROPDOWN
            Obx(() {
              if (controller.isLoadingSubjects.value) {
                return const CircularProgressIndicator();
              }

              return DropdownButtonFormField<int>(
                hint: const Text("Select Subject"),
                value: controller.selectedSubjectId.value,
                isExpanded: true,
                items: controller.subjects.map((subject) {
                  return DropdownMenuItem<int>(
                    value: subject.subjectId,
                    child: Text(
                      subject.subjectName,
                      overflow: TextOverflow.ellipsis, // ✅ safe text
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedSubjectId.value = value;
                    controller.fetchNotes(value);
                  }
                },
              );
            }),

            SizedBox(height: isSmall ? 14 : 20), // ✅ responsive spacing

            // 📄 NOTES LIST
            Expanded(
              child: Obx(() {
                if (controller.isLoadingNotes.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.notes.isEmpty) {
                  return const Center(child: Text("No Notes Available"));
                }

                return ListView.builder(
                  itemCount: controller.notes.length,
                  itemBuilder: (context, index) {
                    final note = controller.notes[index];

                    return Card(
                      margin: EdgeInsets.only(
                          bottom: isSmall ? 10 : 12), // ✅ responsive margin
                      child: Padding(
                        padding: EdgeInsets.all(
                            isSmall ? 10 : 12), // ✅ responsive padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📝 DESCRIPTION
                            Text(
                              note.description,
                              style: TextStyle(
                                fontSize: isSmall ? 14 : 16, // ✅ responsive
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: isSmall ? 8 : 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 👁 VIEW BUTTON
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    size: isSmall ? 20 : 24, // ✅ responsive
                                  ),
                                  onPressed: () {
                                    FileHelper.openFile(note.path);
                                  },
                                ),

                                SizedBox(width: isSmall ? 6 : 8),

                                // ⬇ DOWNLOAD BUTTON
                                Flexible( // ✅ prevents overflow
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      downloadFile(
                                        context,
                                        note.path,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.download,
                                      size: isSmall ? 18 : 20,
                                    ),
                                    label: Text(
                                      "Download",
                                      style: TextStyle(
                                        fontSize: isSmall ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DOWNLOAD FUNCTION (UNCHANGED)
  Future<void> downloadFile(BuildContext context, String url) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await FileDownloader.download(url);

      Get.back();

      if (result == null) return;

      await PdfHandler.handlePdfAction(
        context,
        result.bytes,
        result.filename,
        isDownload: true,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Unexpected error: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class FileHelper {
  static void openFile(String path) {
    if (path.startsWith("http")) {
      if (path.toLowerCase().endsWith(".pdf")) {
        Get.to(() => PDFScreen(url: path));
      } else {
        Get.to(() => ImageScreen(url: path));
      }
    } else {
      if (path.toLowerCase().endsWith(".pdf")) {
        Get.to(() => PDFScreenLocal(path: path));
      } else {
        Get.to(() => ImageScreenLocal(path: path));
      }
    }
  }
}