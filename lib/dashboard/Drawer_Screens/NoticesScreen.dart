
// ignore_for_file: deprecated_member_use
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final noticeController = Get.find<NoticesController>();

  // Returns true only if the notice date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Popup shown only for today's notices
  void _showNoticeDialog(BuildContext context, dynamic notice) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title.isNotEmpty ? notice.title : 'Notice',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Date ─────────────────────────────────────────────────────
              Text(
                "${notice.date.day.toString().padLeft(2, '0')}-"
                "${notice.date.month.toString().padLeft(2, '0')}-"
                "${notice.date.year}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),

              // ── Description ──────────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    notice.description.isNotEmpty
                        ? notice.description
                        : 'No description available.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.55),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Close button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return Center(
            child: Text(
              "No notices yet",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          );
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: RefreshIndicator(
              onRefresh: noticeController.refreshNotices,
              child: isTablet
                  ? _buildGridView(context, noticeController, screenWidth)
                  : _buildListView(context, noticeController),
            ),
          ),
        );
      }),
    );
  }

  // Mobile Layout
  Widget _buildListView(
      BuildContext context, NoticesController controller) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        final notice = controller.notices[index];
        final today = _isToday(notice.date);
        return _NoticeCard(
          notice: notice,
          isGrid: false,
          isToday: today,
          onTap: today ? () => _showNoticeDialog(context, notice) : null,
        );
      },
    );
  }

  // Tablet/Web Layout
  Widget _buildGridView(BuildContext context, NoticesController controller,
      double width) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 900 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        final notice = controller.notices[index];
        final today = _isToday(notice.date);
        return _NoticeCard(
          notice: notice,
          isGrid: true,
          isToday: today,
          onTap: today ? () => _showNoticeDialog(context, notice) : null,
        );
      },
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final dynamic notice;
  final bool isGrid;
  final bool isToday;
  final VoidCallback? onTap; // null = not tappable (non-today notices)

  const _NoticeCard({
    required this.notice,
    required this.isGrid,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // no-op for non-today notices (onTap is null)
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Highlighted border for today's notices
          side: isToday
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        // Tinted background for today's notices
        color: isToday
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title row ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // NEW badge only for today's notices
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    _buildNewTag(context),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Description: shown only for today's notices
              // Non-today notices show only title + date
              if (isToday)
                Text(
                  notice.description,
                  maxLines: isGrid ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                ),

              if (isToday) const SizedBox(height: 16),

              // ── Date ────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${notice.date.day.toString().padLeft(2, '0')}-"
                    "${notice.date.month.toString().padLeft(2, '0')}-"
                    "${notice.date.year}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),

              // Tap hint only for today's notices
              if (isToday) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tap to read more',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        "NEW",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
} */
// notices_screen.dart
// ignore_for_file: deprecated_member_use
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/models/noticesModel.dart';

// ─── Content Type Detection ──────────────────────────────────────────────────

enum NoticeContentType { text, image, pdf, unknown }

class NoticeContentHelper {
  static const _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
  static const _pdfExtensions  = ['.pdf'];

  /// Detects content type from the description string.
  static NoticeContentType detect(String description) {
    if (description.isEmpty) return NoticeContentType.text;
    final lower = description.toLowerCase().trim();
    if (_looksLikeUrl(lower)) {
      if (_imageExtensions.any(lower.contains)) return NoticeContentType.image;
      if (_pdfExtensions.any(lower.contains))   return NoticeContentType.pdf;
      return NoticeContentType.unknown;
    }
    return NoticeContentType.text;
  }

  static bool _looksLikeUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://') || s.startsWith('ftp://');

  /// Returns just the filename portion of a URL, or a fallback label.
  static String fileNameFromUrl(String url) {
    try {
      final uri  = Uri.parse(url);
      final name = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      return name.isNotEmpty ? name : 'file';
    } catch (_) {
      return 'file';
    }
  }
}

// ─── Notice File Action Handler ──────────────────────────────────────────────
// Mirrors the pattern used in PdfHandler so file-handling logic stays modular
// and API integration can be added to `downloadFromUrl` later without touching UI.

class NoticeFileHandler {
  /// Share a file identified by its remote [url].
  /// Currently triggers the system share sheet via [Printing.sharePdf] (works
  /// for both PDF and image bytes once fetched). Swap the fetch call below
  /// when a real API/download service is available.
  static Future<void> shareFile(
    BuildContext context, {
    required String url,
    required String filename,
  }) async {
    try {
      final bytes = await _fetchBytes(url);
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      _snackError('Failed to share file: ${e.toString()}');
    }
  }

  /// Download a file to local storage.
  static Future<void> downloadFile(
    BuildContext context, {
    required String url,
    required String filename,
  }) async {
    try {
      if (Platform.isAndroid && !(await _requestAndroidPermissions())) return;

      final bytes    = await _fetchBytes(url);
      final dir      = await _resolveDirectory();
      if (dir == null) {
        _snackError('Could not resolve storage directory.');
        return;
      }
      if (!await dir.exists()) await dir.create(recursive: true);
      await File('${dir.path}/$filename').writeAsBytes(bytes);
      Get.snackbar(
        'Downloaded',
        '$filename saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _snackError('Failed to download: ${e.toString()}');
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Fetches raw bytes from a URL.
  /// Replace this stub with your actual HTTP client / ApiService call.
  static Future<Uint8List> _fetchBytes(String url) async {
    // TODO: Inject your ApiService / Dio / http client here when ready.
    // Example: return await ApiService().downloadBytes(url);
    throw UnimplementedError(
      'File download not yet wired to the API. '
      'Implement _fetchBytes() with your HTTP client.',
    );
  }

  static Future<Directory?> _resolveDirectory() async {
    if (Platform.isAndroid) {
      final base = Directory('/storage/emulated/0/KI Software Solutions');
      if (await base.exists()) return base;
      try {
        await base.create(recursive: true);
        return base;
      } catch (_) {
        final ext = await getExternalStorageDirectory();
        if (ext == null) return null;
        final parts = ext.path.split('/');
        final prefix = parts
            .takeWhile((p) => p != 'Android')
            .join('/');
        return Directory('$prefix/KI Software Solutions');
      }
    } else if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      return Directory('${docs.path}/KI Software Solutions');
    }
    return null;
  }

  static Future<bool> _requestAndroidPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) status = await Permission.storage.request();
    if (!status.isGranted) {
      var manage = await Permission.manageExternalStorage.status;
      if (!manage.isGranted) manage = await Permission.manageExternalStorage.request();
      if (!manage.isGranted) {
        _snackError('Storage permission is required.');
        return false;
      }
    }
    return true;
  }

  static void _snackError(String msg) => Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
}

// ─── Notices Screen ───────────────────────────────────────────────────────────

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final NoticesController noticeController = Get.find<NoticesController>();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showNoticeDialog(BuildContext context, NoticeModel notice) {
    final contentType = NoticeContentHelper.detect(notice.description);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title.isNotEmpty ? notice.title : 'Notice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Date ───────────────────────────────────────────────────────
              Text(
                "${notice.date.day.toString().padLeft(2, '0')}-"
                "${notice.date.month.toString().padLeft(2, '0')}-"
                "${notice.date.year}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),

              // ── Content ────────────────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: _DialogContent(
                  description: notice.description,
                  contentType: contentType,
                ),
              ),

              const SizedBox(height: 20),

              // ── Close button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return Center(
            child: Text(
              "No notices yet",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          );
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: RefreshIndicator(
              onRefresh: noticeController.refreshNotices,
              child: isTablet
                  ? _buildGridView(context, noticeController, screenWidth)
                  : _buildListView(context, noticeController),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildListView(BuildContext context, NoticesController controller) {
    return ListView.builder(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        final notice = controller.notices[index];
        return _NoticeCard(
          notice: notice,
          isGrid: false,
          isToday: _isToday(notice.date),
          onTap: () => _showNoticeDialog(context, notice),
        );
      },
    );
  }

  Widget _buildGridView(
      BuildContext context, NoticesController controller, double width) {
    return GridView.builder(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 900 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        final notice = controller.notices[index];
        return _NoticeCard(
          notice: notice,
          isGrid: true,
          isToday: _isToday(notice.date),
          onTap: () => _showNoticeDialog(context, notice),
        );
      },
    );
  }
}

// ─── Dialog Content Widget ────────────────────────────────────────────────────

class _DialogContent extends StatelessWidget {
  final String description;
  final NoticeContentType contentType;

  const _DialogContent({
    required this.description,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    switch (contentType) {
      case NoticeContentType.text:
        return _TextContent(description: description);
      case NoticeContentType.image:
        return _ImageContent(url: description);
      case NoticeContentType.pdf:
        return _PdfContent(url: description);
      case NoticeContentType.unknown:
        return _UnknownContent(url: description);
    }
  }
}

// ── Text content ──────────────────────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  final String description;
  const _TextContent({required this.description});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Text(
        description.isNotEmpty ? description : 'No description available.',
        style:
            Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
      ),
    );
  }
}

// ── Image content ─────────────────────────────────────────────────────────────

class _ImageContent extends StatelessWidget {
  final String url;
  const _ImageContent({required this.url});

  @override
  Widget build(BuildContext context) {
    final filename = NoticeContentHelper.fileNameFromUrl(url);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image preview
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => _FileErrorPlaceholder(
                icon: Icons.broken_image_outlined,
                label: 'Image could not be loaded',
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Action row
        _FileActionRow(
          url: url,
          filename: filename,
        ),
      ],
    );
  }
}

// ── PDF content ───────────────────────────────────────────────────────────────

class _PdfContent extends StatelessWidget {
  final String url;
  const _PdfContent({required this.url});

  @override
  Widget build(BuildContext context) {
    final filename = NoticeContentHelper.fileNameFromUrl(url);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PDF icon card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF Document',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Action row
        _FileActionRow(
          url: url,
          filename: filename,
        ),
      ],
    );
  }
}

// ── Unknown / generic URL content ─────────────────────────────────────────────

class _UnknownContent extends StatelessWidget {
  final String url;
  const _UnknownContent({required this.url});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FileErrorPlaceholder(
            icon: Icons.insert_drive_file_outlined,
            label: 'Unsupported content type',
          ),
          const SizedBox(height: 10),
          SelectableText(
            url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }
}

// ── File action row (Download + Share) ────────────────────────────────────────

class _FileActionRow extends StatelessWidget {
  final String url;
  final String filename;

  const _FileActionRow({required this.url, required this.filename});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => NoticeFileHandler.downloadFile(
              context,
              url: url,
              filename: filename,
            ),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => NoticeFileHandler.shareFile(
              context,
              url: url,
              filename: filename,
            ),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Generic error placeholder ─────────────────────────────────────────────────

class _FileErrorPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FileErrorPlaceholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  )),
        ],
      ),
    );
  }
}

// ─── Notice Card ──────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final bool isGrid;
  final bool isToday;
  final VoidCallback onTap; // Now always required — all notices are tappable

  const _NoticeCard({
    required this.notice,
    required this.isGrid,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentType = NoticeContentHelper.detect(notice.description);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isToday
              ? BorderSide(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                )
              : BorderSide.none,
        ),
        color: isToday
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title row ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    _NewTag(),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ── Content preview ───────────────────────────────────────────
              _CardContentPreview(
                description: notice.description,
                contentType: contentType,
                isGrid: isGrid,
                isToday: isToday,
              ),

              const SizedBox(height: 16),

              // ── Date ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${notice.date.day.toString().padLeft(2, '0')}-"
                    "${notice.date.month.toString().padLeft(2, '0')}-"
                    "${notice.date.year}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),

              // ── Tap hint ──────────────────────────────────────────────────
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to read more',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card Content Preview ─────────────────────────────────────────────────────

class _CardContentPreview extends StatelessWidget {
  final String description;
  final NoticeContentType contentType;
  final bool isGrid;
  final bool isToday;

  const _CardContentPreview({
    required this.description,
    required this.contentType,
    required this.isGrid,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    switch (contentType) {
      case NoticeContentType.text:
        if (description.isEmpty) return const SizedBox.shrink();
        return Text(
          description,
          maxLines: isGrid ? 3 : 5,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
        );

      case NoticeContentType.image:
        return SizedBox(
          height: 80,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  description,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.broken_image_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  NoticeContentHelper.fileNameFromUrl(description),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case NoticeContentType.pdf:
        return Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded,
                size: 32, color: Colors.red.shade400),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                NoticeContentHelper.fileNameFromUrl(description),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      case NoticeContentType.unknown:
        return Row(
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: 28,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Attachment',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ),
          ],
        );
    }
  }
}

// ─── NEW Badge ────────────────────────────────────────────────────────────────

class _NewTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        'NEW',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
} */
// notices_screen.dart
// ignore_for_file: deprecated_member_use
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/notice_file_service.dart';

// ─────────────────────────────────────────────────────────────────────────────

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final NoticesController noticeController = Get.find<NoticesController>();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showNoticeDialog(BuildContext context, NoticeModel notice) {
    final url = notice.fileUrl ?? '';
    final contentType = NoticeContentHelper.detect(url);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notice.title.isNotEmpty ? notice.title : "Notice",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "${notice.date.day.toString().padLeft(2, '0')}-"
                "${notice.date.month.toString().padLeft(2, '0')}-"
                "${notice.date.year}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),

              const Divider(height: 20),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: _DialogContent(
                  notice: notice,
                  contentType: contentType,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices"), centerTitle: true),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return const Center(child: Text("No notices yet"));
        }

        return RefreshIndicator(
          onRefresh: noticeController.refreshNotices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noticeController.notices.length,
            itemBuilder: (context, index) {
              final notice = noticeController.notices[index];

              return _NoticeCard(
                notice: notice,
                isToday: _isToday(notice.date),
                onTap: () => _showNoticeDialog(context, notice),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _DialogContent extends StatelessWidget {
  final NoticeModel notice;
  final NoticeContentType contentType;

  const _DialogContent({
    required this.notice,
    required this.contentType,
  });

  @override
  Widget build(BuildContext context) {
    final url = notice.fileUrl ?? '';

    switch (contentType) {
      case NoticeContentType.text:
        return SingleChildScrollView(
          child: Text(
            notice.description.isNotEmpty
                ? notice.description
                : "No description",
          ),
        );

      case NoticeContentType.image:
        return Column(
          children: [
            Image.network(
              url,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image),
            ),
            const SizedBox(height: 10),
            _ActionRow(url: url),
          ],
        );

      case NoticeContentType.pdf:
        return Column(
          children: [
            const Icon(Icons.picture_as_pdf,
                size: 80, color: Colors.red),
            const SizedBox(height: 10),
            Text(notice.description),
            const SizedBox(height: 10),
            _ActionRow(url: url),
          ],
        );

      case NoticeContentType.unknown:
        return Column(
          children: [
            const Icon(Icons.insert_drive_file),
            const SizedBox(height: 10),
            Text(url),
            const SizedBox(height: 10),
            _ActionRow(url: url),
          ],
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final bool isToday;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = notice.fileUrl ?? '';
    final contentType = NoticeContentHelper.detect(url);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title.isNotEmpty ? notice.title : "Notice",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if (contentType == NoticeContentType.text)
                Text(
                  notice.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                )
              else if (contentType == NoticeContentType.image)
                Row(
                  children: [
                    const Icon(Icons.image),
                    const SizedBox(width: 8),
                    Expanded(child: Text(url)),
                  ],
                )
              else if (contentType == NoticeContentType.pdf)
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(url)),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.file_present),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Attachment")),
                  ],
                ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Tap to read more",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String url;

  const _ActionRow({required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => NoticeFileService.downloadFile(
              context,
              url: url,
              filename:
                  NoticeContentHelper.fileNameFromUrl(url),
            ),
            child: const Text("Download"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => NoticeFileService.shareFile(
              context,
              url: url,
              filename:
                  NoticeContentHelper.fileNameFromUrl(url),
            ),
            child: const Text("Share"),
          ),
        ),
      ],
    );
  }
} */
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/notice_file_service.dart';

// ─────────────────────────────────────────────────────────────────────────────

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final NoticesController noticeController = Get.find<NoticesController>();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showNoticeDialog(BuildContext context, NoticeModel notice) {
    final url = notice.fileUrl ?? '';
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.05,
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notice.title.isNotEmpty ? notice.title : "Notice",
                      style: TextStyle(
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "${notice.date.day.toString().padLeft(2, '0')}-"
                "${notice.date.month.toString().padLeft(2, '0')}-"
                "${notice.date.year}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isSmall ? 11 : 12,
                ),
              ),

              const Divider(height: 20),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    notice.description.isNotEmpty
                        ? notice.description
                        : "No description available",
                    style: TextStyle(fontSize: isSmall ? 13 : 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (url.isNotEmpty) _AttachmentPreview(url: url),

              if (url.isNotEmpty) const SizedBox(height: 12),

              if (url.isNotEmpty) _ActionRow(url: url),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices"), centerTitle: true),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
         if (noticeController.errorMessage.isNotEmpty) {
    return Center(
      child: Text(
        noticeController.errorMessage.value,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }


        if (noticeController.notices.isEmpty) {
          return const Center(child: Text("No notices yet"));
        }

        return RefreshIndicator(
          onRefresh: noticeController.refreshNotices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: noticeController.notices.length,
            itemBuilder: (context, index) {
              final notice = noticeController.notices[index];

              return _NoticeCard(
                notice: notice,
                isToday: _isToday(notice.date),
                onTap: () => _showNoticeDialog(context, notice),
              );
            },
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTICE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final bool isToday;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title.isNotEmpty ? notice.title : "Notice",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "${notice.date.day.toString().padLeft(2, '0')}-"
                "${notice.date.month.toString().padLeft(2, '0')}-"
                "${notice.date.year}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Read More",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTACHMENT PREVIEW (RESPONSIVE + THEME SAFE)
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentPreview extends StatelessWidget {
  final String url;

  const _AttachmentPreview({required this.url});

  bool get isImage =>
      url.contains(".png") ||
      url.contains(".jpg") ||
      url.contains(".jpeg");

  bool get isPdf => url.contains(".pdf");

  String get fileName => url.split('/').last.split('?').first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final boxSize = size.width * 0.14;

    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: boxSize,
            width: boxSize,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isImage
                  ? Image.network(url, fit: BoxFit.cover)
                  : Icon(
                      isPdf
                          ? Icons.picture_as_pdf
                          : Icons.insert_drive_file,
                      color: isPdf
                          ? Colors.red
                          : theme.iconTheme.color,
                    ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
         
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION ROW
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final String url;

  const _ActionRow({required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => NoticeFileService.downloadFile(
              context,
              url: url,
              filename: url.split('/').last,
            ),
            child: const Text("Download"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => NoticeFileService.shareFile(
              context,
              url: url,
              filename: url.split('/').last,
            ),
            child: const Text("Share"),
          ),
        ),
      ],
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/notice_details_dialog.dart';
import 'package:school_management_system/utils/app_footer.dart';

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final NoticesController controller = Get.find<NoticesController>();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
      ),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (controller.notices.isEmpty) {
          return const Center(child: Text("No notices available"));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notices.length,
            itemBuilder: (context, index) {
              final notice = controller.notices[index];
              final isToday = _isToday(notice.date);

              return _NoticeCard(
                notice: notice,
                isToday: isToday,
                onTap: () {
                  showNoticeDetails(context, notice);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final bool isToday;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isToday ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isToday ? Colors.blue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title.isNotEmpty ? notice.title : "Notice",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                notice.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${notice.date.day.toString().padLeft(2, '0')}-"
                    "${notice.date.month.toString().padLeft(2, '0')}-"
                    "${notice.date.year}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  Text(
                    "Read More →",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}