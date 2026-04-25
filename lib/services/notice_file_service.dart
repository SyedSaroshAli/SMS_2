// notice_file_service.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:http/http.dart' as http;

// ─── Content Type Detection ───────────────────────────────────────────────────
//
// Detection is always performed on the `imagePdf` URL field, never on the
// text description.  This matches the actual API response structure where
// `imagePdf` holds the remote file URL.

enum NoticeContentType { text, image, pdf, unknown }

class NoticeContentHelper {
  static const _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
  ];
  static const _pdfExtensions = ['.pdf'];

  /// Detect the content type from [url] (the `imagePdf` field).
  /// Returns [NoticeContentType.text] when [url] is blank (no attachment).
  static NoticeContentType detect(String url) {
    if (url.isEmpty) return NoticeContentType.text;
    final lower = url.toLowerCase().split('?').first; // strip query params
    if (!_looksLikeUrl(lower)) return NoticeContentType.text;
    if (_imageExtensions.any(lower.endsWith)) return NoticeContentType.image;
    if (_pdfExtensions.any(lower.endsWith)) return NoticeContentType.pdf;
    return NoticeContentType.unknown;
  }

  static bool _looksLikeUrl(String s) =>
      s.startsWith('http://') ||
      s.startsWith('https://') ||
      s.startsWith('ftp://');

  /// Extract just the filename from a URL, falling back to `'file'`.
  static String fileNameFromUrl(String url) {
    try {
      final cleanUrl = url.split('?').first;
      final uri = Uri.parse(cleanUrl);
      final name = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      return name.isNotEmpty ? name : 'file';
    } catch (_) {
      return 'file';
    }
  }
}

// ─── Notice File Service ──────────────────────────────────────────────────────
//
// Single responsibility: download a file from a URL and either save it locally
// or push it to the system share sheet.
//
// Storage folder is intentionally IDENTICAL to PdfHandler so all downloaded
// files end up in the same place:
//   Android  →  /storage/emulated/0/KI Software Solutions/
//   iOS      →  <Documents>/KI Software Solutions/

class NoticeFileService {
  static final AuthService _authService = AuthService();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Download [url] and save to local storage.
  static Future<void> downloadFile(
    BuildContext context, {
    required String url,
    required String filename,
  }) async {
    try {
      if (Platform.isAndroid) await _requestAndroidPermissions();

      final bytes = await _fetchBytes(url);
      if (bytes == null) return; // error already shown

      final dir = await _resolveStorageDirectory();
      if (dir == null) {
        _snack(
          'Error',
          'Could not find a writable storage directory.',
          color: Colors.red,
        );
        return;
      }

      final timestampedFilename = _addTimestamp(filename);
      final file = File('${dir.path}/$timestampedFilename');
      await file.writeAsBytes(bytes, flush: true);

      if (!await file.exists()) {
        _snack(
          'Error',
          'File was not saved. Try sharing instead.',
          color: Colors.red,
        );
        return;
      }

      final friendly = file.path
          .replaceFirst('/storage/emulated/0/', 'Internal Storage/')
          .replaceFirst('/data/user/0/', 'App Storage/');
      _snack('Downloaded', 'Saved to: $friendly', color: Colors.green);
    } catch (e) {
      _snack('Error', 'Failed to download: ${e.toString()}', color: Colors.red);
    }
  }

  /// Download [url] and push to system share sheet.
  static Future<void> shareFile(
    BuildContext context, {
    required String url,
    required String filename,
  }) async {
    try {
      final bytes = await _fetchBytes(url);
      if (bytes == null) return; // error already shown
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      _snack('Error', 'Failed to share: ${e.toString()}', color: Colors.red);
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Downloads raw bytes from [url] with JWT auth header.
  /// Validates the response is a real file (via magic bytes) before returning.
  /// Returns `null` and shows a snackbar on any failure.
  static Future<Uint8List?> _fetchBytes(String url) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/pdf, image/*, application/octet-stream, */*',
          'User-Agent': 'SchoolManagementApp/1.0',
        },
      );

      // ── 1. HTTP status check ───────────────────────────────────────────
      if (response.statusCode == 401) {
        _snack(
          'Error',
          'Session expired. Please log in again.',
          color: Colors.red,
        );
        return null;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _snack(
          'Error',
          'Server returned ${response.statusCode}. Please try again.',
          color: Colors.red,
        );
        return null;
      }

      // ── 2. Guard against HTML / JSON error pages ───────────────────────
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('text/html') ||
          contentType.contains('application/json')) {
        debugPrint(
          '⚠️ NoticeFileService: server returned $contentType instead of a file.',
        );
        _snack(
          'Error',
          'The server returned an error page. Check your connection.',
          color: Colors.red,
        );
        return null;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        _snack('Error', 'Downloaded file is empty.', color: Colors.red);
        return null;
      }

      // ── 3. Magic-byte validation ───────────────────────────────────────
      if (!_isValidFileMagic(bytes)) {
        debugPrint(
          '⚠️ NoticeFileService: unknown magic bytes '
          '${bytes.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
        _snack(
          'Error',
          'Downloaded file is not a valid PDF or image.',
          color: Colors.red,
        );
        return null;
      }

      return bytes;
    } catch (e) {
      _snack('Error', 'Network error: ${e.toString()}', color: Colors.red);
      return null;
    }
  }

  /// Returns `true` when [bytes] start with a known file signature.
  static bool _isValidFileMagic(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // PDF  %PDF  →  25 50 44 46
    if (bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46)
      return true;

    // PNG        →  89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47)
      return true;

    // JPEG       →  FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;

    // GIF        →  47 49 46 38
    if (bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38)
      return true;

    // WEBP  RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 && // RI
        bytes[8] == 0x57 &&
        bytes[9] == 0x45) // WE
      return true;

    // BMP        →  42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;

    return false;
  }

  // ── Timestamp helper ───────────────────────────────────────────────────────

  static String _addTimestamp(String filename) {
    final now = DateTime.now();
    final ts =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final dot = filename.lastIndexOf('.');
    if (dot == -1) return '${filename}_$ts';
    return '${filename.substring(0, dot)}_$ts${filename.substring(dot)}';
  }

  // ── Storage directory ──────────────────────────────────────────────────────

  static Future<Directory?> _resolveStorageDirectory() async {
    const folderName = 'KI Software Solutions';

    if (Platform.isAndroid) {
      // Attempt 1 — public Downloads sub-folder (hardcoded primary path)
      final d1 = await _tryDir('/storage/emulated/0/Download/$folderName');
      if (d1 != null) return d1;

      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        // Attempt 2 — build Downloads path from external storage dir
        final parts = ext.path.split('/');
        final androidIdx = parts.indexOf('Android');
        if (androidIdx > 0) {
          final base = parts.sublist(0, androidIdx).join('/');
          final d2 = await _tryDir('$base/Download/$folderName');
          if (d2 != null) return d2;

          // Attempt 3 — root of external storage (visible in Files app)
          final d3 = await _tryDir('$base/$folderName');
          if (d3 != null) return d3;
        }

        // Attempt 4 — app-private external (always writable)
        final appExt = Directory('${ext.path}/$folderName');
        if (!await appExt.exists()) await appExt.create(recursive: true);
        return appExt;
      }
    }

    if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/$folderName');
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }

    return null;
  }

  /// Creates [path] if needed, performs a write-test, returns null on failure.
  static Future<Directory?> _tryDir(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) await dir.create(recursive: true);
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsBytes([0x00]);
      await probe.delete();
      return dir;
    } catch (_) {
      return null;
    }
  }

  // ── Android permissions ────────────────────────────────────────────────────

  static Future<void> _requestAndroidPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted && !status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      final manage = await Permission.manageExternalStorage.status;
      if (!manage.isGranted && !manage.isPermanentlyDenied) {
        await Permission.manageExternalStorage.request();
      }
      // Do not return false — the write-test decides actual access.
    }
  }

  // ── Snackbar helper ────────────────────────────────────────────────────────

  static void _snack(
    String title,
    String message, {
    Color color = Colors.grey,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
