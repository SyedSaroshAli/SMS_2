import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class PdfHandler {
  static const _folderName = 'KI Software Solutions';

  /// Handles the action of either sharing or downloading the generated PDF.
  static Future<void> handlePdfAction(
    BuildContext context,
    Uint8List bytes,
    String filename, {
    required bool isDownload,
  }) async {
    if (!isDownload) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }

    try {
      // Request permissions — on Android 11+ we proceed even if storage
      // permission is "denied" and rely on scoped storage access instead.
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      final directory = Platform.isAndroid
          ? await _resolveAndroidDirectory()
          : await _resolveIosDirectory();

      if (directory == null) {
        _showError("Could not find a writable storage directory.");
        return;
      }

      final timestampedFilename = _addTimestamp(filename);
      final file = File('${directory.path}/$timestampedFilename');
      await file.writeAsBytes(bytes, flush: true);

      // Confirm the file actually landed on disk
      if (!await file.exists()) {
        _showError("File was not saved. Try sharing instead.");
        return;
      }

      Get.snackbar(
        "Downloaded",
        "Saved to: ${_friendlyPath(file.path)}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint("PdfHandler save error: $e");
      _showError("Failed to save PDF: ${e.toString()}");
    }
  }

  // ── Directory resolution ──────────────────────────────────────────────────

  /// Tries three locations in order, returning the first one that is writable.
  ///
  ///  1. /storage/emulated/0/Downloads/KI Software Solutions  ← ideal
  ///  2. /storage/emulated/0/KI Software Solutions             ← still visible
  ///  3. App's private external-files dir                      ← always works
  static Future<Directory?> _resolveAndroidDirectory() async {
    // Attempt 1 — public Downloads sub-folder
    final dl = await _tryDir('/storage/emulated/0/Download/$_folderName');
    if (dl != null) return dl;

    // Attempt 2 — build the Downloads path dynamically from getExternalStorageDirectory
    //            (handles edge cases where emulated path differs)
    final ext = await getExternalStorageDirectory();
    if (ext != null) {
      final parts = ext.path.split('/');
      final androidIdx = parts.indexOf('Android');
      if (androidIdx > 0) {
        final base = parts.sublist(0, androidIdx).join('/');
        final dl2 = await _tryDir('$base/Download/$_folderName');
        if (dl2 != null) return dl2;

        // Attempt 3 — root of external storage (still visible in Files app)
        final root2 = await _tryDir('$base/$_folderName');
        if (root2 != null) return root2;
      }

      // Attempt 4 — app-private external storage (always writable, accessible
      //             via "Android > data > <package>" in Files app)
      final appExt = Directory('${ext.path}/$_folderName');
      if (!await appExt.exists()) await appExt.create(recursive: true);
      return appExt;
    }

    return null;
  }

  static Future<Directory?> _resolveIosDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_folderName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Creates [path] if needed, performs a write-test, and returns the
  /// [Directory] only when we can actually write to it.  Returns null on any
  /// failure so the caller can try the next candidate.
  static Future<Directory?> _tryDir(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      // Write-test: create + delete a tiny probe file
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsBytes([0x00]);
      await probe.delete();
      return dir;
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _addTimestamp(String filename) {
    final now = DateTime.now();
    final ts =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final dot = filename.lastIndexOf('.');
    if (dot == -1) return '${filename}_$ts';
    return '${filename.substring(0, dot)}_$ts${filename.substring(dot)}';
  }

  /// Strips the /storage/emulated/0 prefix to keep the snackbar readable.
  static String _friendlyPath(String path) {
    return path
        .replaceFirst('/storage/emulated/0/', 'Internal Storage/')
        .replaceFirst('/data/user/0/', 'App Storage/');
  }

  static void _showError(String message) {
    Get.snackbar(
      "Download Failed",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Requests storage permission.  On Android 13+ WRITE_EXTERNAL_STORAGE is
  /// deprecated; we still attempt it and fall through so the write-test in
  /// [_tryDir] decides whether we have access.
  static Future<void> _requestAndroidPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      // Android 11+ — request MANAGE_EXTERNAL_STORAGE (shown once; user must
      // grant manually in Settings if denied permanently).
      final manage = await Permission.manageExternalStorage.status;
      if (!manage.isGranted && !manage.isPermanentlyDenied) {
        await Permission.manageExternalStorage.request();
      }
      // We do NOT return false here — the write-test will determine access.
    }
  }

  // ── PDF action menu ───────────────────────────────────────────────────────

  /// Builds a standard PopupMenuButton with 'Share PDF' and 'Download PDF'.
  static Widget buildPdfActionMenu(
    BuildContext context,
    Function(bool isDownload) onAction, {
    bool isLoading = false,
    Widget? customChild,
  }) {
    if (isLoading) {
      return customChild ??
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
    }

    return PopupMenuButton<String>(
      icon: customChild == null ? const Icon(Icons.picture_as_pdf) : null,
      child: customChild,
      tooltip: 'PDF Options',
      onSelected: (value) {
        onAction(value == 'download');
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.black54),
              SizedBox(width: 12),
              Text('Share PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, color: Colors.black54),
              SizedBox(width: 12),
              Text('Download PDF'),
            ],
          ),
        ),
      ],
    );
  }
}
