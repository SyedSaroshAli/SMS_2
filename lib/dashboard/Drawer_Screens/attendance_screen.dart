import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_management_system/controllers/about_controller.dart';
import 'package:school_management_system/services/about_service.dart';
//import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_management_system/models/about_model.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';
import 'package:http/http.dart' as http;

/*
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Action Buttons
              _ActionButtons(controller: controller),

              // Expandable Filter
              _ExpandableFilter(controller: controller),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (controller.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: "Present",
                            count: controller.presentCount,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.cancel,
                            label: "Absent",
                            count: controller.absentCount,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.event_busy,
                            label: "Late",
                            count: controller.leaveCount,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Daily Records Header
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Records List
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Action buttons row (Filter + Generate PDF)
class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.toggleFilter,
              icon: Icon(
                Icons.filter_alt,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isGeneratingPdf.value
                    ? null
                    : () => _generatePdf(context),
                icon: controller.isGeneratingPdf.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.picture_as_pdf,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                label: Text(
                  controller.isGeneratingPdf.value
                      ? 'Generating...'
                      : 'Generate PDF',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    controller.isGeneratingPdf.value = true;
    try {
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;

      final presentCount = controller.presentCount;
      final absentCount = controller.absentCount;
      final leaveCount = controller.leaveCount;
      final totalDays = records.length;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPdfHeader(),
              pw.SizedBox(height: 20),
              _buildPdfTitle(),
              pw.SizedBox(height: 20),
              _buildPdfStudentInfo(info),
              pw.SizedBox(height: 20),
              _buildPdfMonthAndSummary(
                controller.selectedMonth.value,
                presentCount,
                absentCount,
                leaveCount,
                totalDays,
              ),
              pw.SizedBox(height: 20),
              _buildPdfAttendanceTable(
                records
                    .map(
                      (r) => {
                        'date': r.date,
                        'status': controller.normalizeStatus(r.status),
                      },
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );

      // Save to Downloads/KI Software Solutions
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission required'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      const String folderName = 'KI Software Solutions';
      final Directory saveDir = Directory('/storage/emulated/0/Download/$folderName');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final String rawName = 'Attendance_\${info['name'] ?? 'Student'}_\${controller.selectedMonth.value}.pdf';
      final String safeFileName = rawName.replaceAll(RegExp(r'[\\\\/:*?\"<>| ]'), '_');
      final File output = File('\${saveDir.path}/\$safeFileName');
      final Uint8List bytes = await pdf.save();
      await output.writeAsBytes(bytes);

      if (await output.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved to Downloads/$folderName/\$safeFileName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('File save failed');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 70,
          height: 70,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFF1A3A5C),
              width: 2.5,
            ),
            color: PdfColors.white,
          ),
          child: pw.Center(
            child: pw.Icon(
              const pw.IconData(0xe491),
              size: 35,
              color: const PdfColor.fromInt(0xFF1A3A5C),
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'BENCHMARK',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF1A3A5C),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'School of leadership',
                    style: const pw.TextStyle(
                      fontSize: 18,
                      color: PdfColor.fromInt(0xFF5DADE2),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 300, height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text(
                'PLAY GROUP TO MATRIC',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'ATTENDANCE RECORD',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
        ),
      ],
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Name: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      info['name'] ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Roll No: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      info['rollNo'] ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Father Name: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      info['fatherName'] ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Class: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      info['class'] ?? '',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfMonthAndSummary(
    String month,
    int present,
    int absent,
    int leave,
    int total,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MONTH INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      'Month: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(month, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ATTENDANCE SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  height: 1,
                  color: PdfColors.grey400,
                ),
                pw.SizedBox(height: 8),
                _pdfSummaryRow('Total Present:', present.toString()),
                _pdfSummaryRow('Total Absent:', absent.toString()),
                _pdfSummaryRow('Total Leave:', leave.toString()),
                _pdfSummaryRow('Total Days:', total.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfAttendanceTable(List<Map<String, String>> records) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfTableCell('Sr No', isHeader: true),
            _pdfTableCell('Date', isHeader: true),
            _pdfTableCell('Status', isHeader: true),
          ],
        ),
        ...records.asMap().entries.map((entry) {
          return pw.TableRow(
            children: [
              _pdfTableCell((entry.key + 1).toString()),
              _pdfTableCell(entry.value['date']!),
              _pdfTableCell(entry.value['status']!),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}

/// Expandable month filter
class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isFilterExpanded.value) return const SizedBox.shrink();

      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Select Month",
              filled: true,
              prefixIcon: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            initialValue: controller.selectedMonth.value,
            isExpanded: true,
            items: AttendanceController.months.map((month) {
              return DropdownMenuItem(value: month, child: Text(month));
            }).toList(),
            onChanged: (value) {
              if (value != null) controller.setMonth(value);
            },
          ),
        ),
      );
    });
  }
}

/// Statistics card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Records list card
class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.filteredRecords;

      return Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 400,
          child: records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Records for This Month",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final status = controller.normalizeStatus(record.status);
                    Color statusColor;
                    IconData statusIcon;

                    if (status == 'Present') {
                      statusColor = const Color(0xFF10B981);
                      statusIcon = Icons.check_circle;
                    } else if (status == 'Absent') {
                      statusColor = const Color(0xFFEF4444);
                      statusIcon = Icons.cancel;
                    } else {
                      statusColor = const Color(0xFFF59E0B);
                      statusIcon = Icons.event_busy;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                record.date,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 14, color: statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      );
    });
  }
} 

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Attendance"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // --- Top Action Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.toggleFilter(),
                    icon: const Icon(Icons.filter_alt_outlined, size: 18),
                    label: const Text("Filter"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue[800]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {}, // Trigger PDF generation
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text("Generate PDF",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Expandable Filter Section ---
          Obx(() => AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: controller.isFilterExpanded.value
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month Dropdown
                            const Text("Select Month", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: controller.selectedMonth.value,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.calendar_month, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              items: AttendanceController.months
                                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                  .toList(),
                              onChanged: (val) => controller.setMonth(val!),
                            ),
                            const SizedBox(height: 16),
                            
                            // Year Dropdown - Added exactly below Month
                            const Text("Select Year", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: controller.selectedYear.value,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.history, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              items: controller.availableYears
                                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                                  .toList(),
                              onChanged: (val) => controller.setYear(val!),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )),

          // --- Main Content Area ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary Stats Cards
                    Row(
                      children: [
                        _buildStatCard("Present", controller.presentCount.toString(), Colors.green),
                        const SizedBox(width: 8),
                        _buildStatCard("Absent", controller.absentCount.toString(), Colors.red),
                        const SizedBox(width: 8),
                        _buildStatCard("Late", controller.leaveCount.toString(), Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Daily Records Header
                    Row(
                      children: [
                        Icon(Icons.history, size: 20, color: Colors.blue[900]),
                        const SizedBox(width: 8),
                        const Text("Daily Records", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List of Records or Empty State
                    controller.filteredRecords.isEmpty
                        ? _buildEmptyState()
                        : _buildRecordsList(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              label == "Present" ? Icons.check_circle : (label == "Absent" ? Icons.cancel : Icons.calendar_today),
              color: color.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text("No Records for This Month", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredRecords.length,
      itemBuilder: (context, index) {
        final record = controller.filteredRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(record.date),
            trailing: Text(
              controller.normalizeStatus(record.status),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
            ),
          ),
        );
      },
    );
  }
}
*/
/* CORRECT CODE 
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Action Buttons (Filter + PDF)
              _ActionButtons(controller: controller),

              // Expandable Filter
              _ExpandableFilter(controller: controller),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorCard(context, controller.errorMessage.value),

                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: "Present",
                            count: controller.presentCount,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.cancel,
                            label: "Absent",
                            count: controller.absentCount,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.event_busy,
                            label: "Late",
                            count: controller.leaveCount,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Daily Records Header
                    Row(
                      children: [
                        Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Action Buttons with Integrated PDF Logic ---
class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.toggleFilter,
              icon: const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
              label: const Text('Filter', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Generate PDF Button
          Expanded(
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isGeneratingPdf.value ? null : () => _generatePdf(context),
              icon: controller.isGeneratingPdf.value
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf, size: 20, color: Colors.white),
              label: Text(
                controller.isGeneratingPdf.value ? 'Generating...' : 'Generate PDF',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                disabledBackgroundColor: Colors.grey,
              ),
            )),
          ),
        ],
      ),
    );
  }

  /// PDF Generation Logic
  Future<void> _generatePdf(BuildContext context) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;
    try {
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final interRegular = pw.Font.helvetica();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader( merriweatherBold, dancingScriptBold, interBold),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      // Using layoutPdf for high reliability on Web and Mobile
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Attendance_${info['name']}_${controller.selectedMonth.value}.pdf',
      );

    } catch (e) {
      Get.snackbar("Error", "Failed to generate PDF: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  // --- PDF Component Builders ---

 pw.Widget _buildPdfHeader(pw.Font titleFont, pw.Font subTitleFont, pw.Font boldFont) {
  return pw.Center(child: pw.Padding(
    padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10), // Reduced side padding for better centering
    child: pw.Column(
      // This ensures all children in the column are centered horizontally
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          "BENCHMARK",
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 25,
            color: const PdfColor.fromInt(0xFF1E3A8A),
          ),
        ),
        pw.Text(
          "School of Leadership",
          style: pw.TextStyle(
            font: subTitleFont,
            fontSize: 22,
            color: const PdfColor.fromInt(0xFF0284C7),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF1E293B),
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
          ),
          child: pw.Text(
            "PLAY GROUP TO MATRIC",
            style: pw.TextStyle(
              font: boldFont,
              color: PdfColors.white,
              fontSize: 16,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
      ],
    ),
  ),);
}

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('ATTENDANCE RECORD', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(
        children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Name: ${info['name']}'),
          ]),
          pw.SizedBox(height: 5), 
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text('Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}')),
        pw.Text('P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}'),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(AttendanceController controller, List records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }
}

// --- Reusable UI Components (Simplified for brevity) ---

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) return const Center(child: Text("No records found"));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return ListTile(
          title: Text(r.date),
          trailing: Text(controller.normalizeStatus(r.status)),
        );
      },
    );
  }
}

class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isFilterExpanded.value
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: DropdownButton<String>(
                  value: controller.selectedMonth.value,
                  items: AttendanceController.months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => controller.setMonth(v!),
                )),
                const SizedBox(width: 10),
                Expanded(child: DropdownButton<String>(
                  value: controller.selectedYear.value,
                  items: controller.availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                  onChanged: (v) => controller.setYear(v!),
                )),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
} */

/*
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    // Get device dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            // Best practice: Limit width for larger screens (Tablets/Web)
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Action Buttons (Filter + PDF) - Made responsive
                  _ActionButtons(controller: controller),

                  // Expandable Filter
                  _ExpandableFilter(controller: controller),

                  Padding(
                    padding: EdgeInsets.all(screenWidth > 600 ? 30 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.errorMessage.value.isNotEmpty)
                          _buildErrorCard(context, controller.errorMessage.value),

                        // Statistics Cards - Swaps to horizontal scroll or smaller sizing on tiny screens
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.check_circle,
                                    label: "Present",
                                    count: controller.presentCount,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                SizedBox(width: constraints.maxWidth * 0.03),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.cancel,
                                    label: "Absent",
                                    count: controller.absentCount,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                                SizedBox(width: constraints.maxWidth * 0.03),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.event_busy,
                                    label: "Late",
                                    count: controller.leaveCount,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Daily Records Header
                        Row(
                          children: [
                            Icon(Icons.history,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              "Daily Records",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _RecordsList(controller: controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Action Buttons with Integrated PDF Logic ---
class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(builder: (context, constraints) {
        // Switch to column for very narrow screens if necessary, 
        // but for buttons, a responsive Row usually suffices.
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.toggleFilter,
                icon: const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
                label: const Text('Filter',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isGeneratingPdf.value
                        ? null
                        : () => _generatePdf(context),
                    icon: controller.isGeneratingPdf.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf,
                            size: 20, color: Colors.white),
                    label: Text(
                      controller.isGeneratingPdf.value
                          ? 'Generating...'
                          : 'Generate PDF',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: Colors.grey,
                    ),
                  )),
            ),
          ],
        );
      }),
    );
  }

  /// PDF Generation Logic
  Future<void> _generatePdf(BuildContext context) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;
    try {
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader(merriweatherBold, dancingScriptBold, interBold),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'Attendance_${info['name']}_${controller.selectedMonth.value}.pdf',
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to generate PDF: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(
      pw.Font titleFont, pw.Font subTitleFont, pw.Font boldFont) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              "BENCHMARK",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 25,
                color: const PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
            pw.Text(
              "School of Leadership",
              style: pw.TextStyle(
                font: subTitleFont,
                fontSize: 22,
                color: const PdfColor.fromInt(0xFF0284C7),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
              ),
              child: pw.Text(
                "PLAY GROUP TO MATRIC",
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('ATTENDANCE RECORD',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(
        children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Name: ${info['name']}'),
          ]),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(
            child: pw.Text(
                'Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}')),
        pw.Text(
            'P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}'),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(
      AttendanceController controller, List records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth > 600 ? 32 : 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth > 600 ? 14 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: screenWidth > 600 ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) return const Center(child: Text("No records found"));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(r.date, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.normalizeStatus(r.status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isFilterExpanded.value
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap( // Wrap is better for responsiveness than Row
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 24,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Month", border: OutlineInputBorder()),
                    value: controller.selectedMonth.value,
                    items: AttendanceController.months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => controller.setMonth(v!),
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 24,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Year", border: OutlineInputBorder()),
                    value: controller.selectedYear.value,
                    items: controller.availableYears
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (v) => controller.setYear(v!),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink());
  }
}  */
/*
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 600 ? 30 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionButtons(controller: controller),
                    _ExpandableFilter(controller: controller),
                    const SizedBox(height: 16),

                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorCard(context, controller.errorMessage.value),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: "Present",
                                count: controller.presentCount,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.cancel,
                                label: "Absent",
                                count: controller.absentCount,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.event_busy,
                                label: "Late",
                                count: controller.leaveCount,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Icon(Icons.history,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.toggleFilter,
              icon: const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
              label: const Text('Filter',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isGeneratingPdf.value
                      ? null
                      : () => _generatePdf(context),
                  icon: controller.isGeneratingPdf.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.picture_as_pdf,
                          size: 20, color: Colors.white),
                  label: Text(
                    controller.isGeneratingPdf.value
                        ? 'Generating...'
                        : 'Generate PDF',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey,
                  ),
                )),
          ),
        ],
      );
    });
  }

  Future<void> _generatePdf(BuildContext context) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;
    try {
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader(merriweatherBold, dancingScriptBold, interBold),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'Attendance_${info['name']}_${controller.selectedMonth.value}.pdf',
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to generate PDF: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  pw.Widget _buildPdfHeader(
      pw.Font titleFont, pw.Font subTitleFont, pw.Font boldFont) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              "BENCHMARK",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 25,
                color: const PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
            pw.Text(
              "School of Leadership",
              style: pw.TextStyle(
                font: subTitleFont,
                fontSize: 22,
                color: const PdfColor.fromInt(0xFF0284C7),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
              ),
              child: pw.Text(
                "PLAY GROUP TO MATRIC",
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('ATTENDANCE RECORD',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('Name: ${info['name']}')]),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(
            child: pw.Text(
                'Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}')),
        pw.Text(
            'P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}'),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(
      AttendanceController controller, List records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth > 600 ? 32 : 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth > 600 ? 14 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: screenWidth > 600 ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) return const Center(child: Text("No records found"));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(r.date,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.normalizeStatus(r.status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ✅ ONLY FIX: early return eliminates the blank space when collapsed
class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Early return = zero height, zero space when collapsed
      if (!controller.isFilterExpanded.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Month", border: OutlineInputBorder()),
                value: controller.selectedMonth.value,
                items: AttendanceController.months
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => controller.setMonth(v!),
              ),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Year", border: OutlineInputBorder()),
                value: controller.selectedYear.value,
                items: controller.availableYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => controller.setYear(v!),
              ),
            ),
          ],
        ),
      );
    });
  }
} */
/*
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 600 ? 30 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionButtons(controller: controller),
                    _ExpandableFilter(controller: controller),
                    const SizedBox(height: 16),

                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorCard(context, controller.errorMessage.value),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: "Present",
                                count: controller.presentCount,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.cancel,
                                label: "Absent",
                                count: controller.absentCount,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.event_busy,
                                label: "Late",
                                count: controller.leaveCount,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Icon(Icons.history,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _ActionButtons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.toggleFilter,
              icon: const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
              label: const Text('Filter',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isGeneratingPdf.value
                      ? null
                      : () => _generatePdf(context),
                  icon: controller.isGeneratingPdf.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.picture_as_pdf,
                          size: 20, color: Colors.white),
                  label: Text(
                    controller.isGeneratingPdf.value
                        ? 'Generating...'
                        : 'Generate PDF',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey,
                  ),
                )),
          ),
        ],
      );
    });
  }

  // ── ONLY THIS METHOD HAS CHANGED ──────────────────────────────────────────
  Future<void> _generatePdf(BuildContext context) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;

    try {
      // ── 1. Request storage permission (Android 10 needs it for /Downloads) ──
      PermissionStatus status;

      if (Platform.isAndroid) {
        // Android 13+ (SDK 33+) no longer needs WRITE_EXTERNAL_STORAGE
        // for app-specific or MediaStore paths, but for direct /Downloads
        // access we request it on ≤ Android 12 and use manageExternalStorage
        // or the MediaStore approach on 13+. The cleanest cross-version path:
        // request storage; on Android 13+ it auto-grants for Downloads.
        status = await Permission.storage.request();

        // On Android 13+ (status may be permanentlyDenied for legacy perm)
        // fall back to manageExternalStorage if needed.
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (!status.isGranted) {
          Get.snackbar(
            "Permission Denied",
            "Storage permission is required to save the PDF.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      // ── 2. Resolve the Downloads/KI Software Solutions folder ────────────
      //
      // On Android the external storage Downloads directory is always at
      // /storage/emulated/0/Download  (note: singular, no 's' on some OEMs).
      // Using the hard-coded path is the most reliable option; path_provider's
      // getExternalStorageDirectory() returns the app-specific directory, NOT
      // the public Downloads folder.
      //
      const String folderName = 'KI Software Solutions';
      final Directory downloadsDir =
          Directory('/storage/emulated/0/Download');

      final Directory saveDir =
          Directory('${downloadsDir.path}/$folderName');

      // ── 3. Create the folder if it does not exist ─────────────────────────
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      // ── 4. Build the PDF (identical to original logic) ────────────────────
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildPdfHeader(merriweatherBold, dancingScriptBold, interBold),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      // ── 5. Save bytes directly to the file ───────────────────────────────
      final String fileName =
          'Attendance_${info['name']}_${controller.selectedMonth.value}_'
          '${controller.selectedYear.value}.pdf';

      // Sanitise the file name so it has no characters illegal on Android FS
      final String safeFileName =
          fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      final File outputFile = File('${saveDir.path}/$safeFileName');
      final List<int> pdfBytes = await pdf.save();

      await outputFile.writeAsBytes(pdfBytes, flush: true);

      // ── 6. Success feedback ───────────────────────────────────────────────
      Get.snackbar(
        "PDF Saved",
        "Saved to: ${outputFile.path}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FileSystemException catch (e) {
      Get.snackbar(
        "Save Failed",
        "File error: ${e.message} — ${e.path}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate PDF: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }
  // ── END OF CHANGED METHOD ─────────────────────────────────────────────────

  pw.Widget _buildPdfHeader(
      pw.Font titleFont, pw.Font subTitleFont, pw.Font boldFont) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              "BENCHMARK",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 25,
                color: const PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
            pw.Text(
              "School of Leadership",
              style: pw.TextStyle(
                font: subTitleFont,
                fontSize: 22,
                color: const PdfColor.fromInt(0xFF0284C7),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
              ),
              child: pw.Text(
                "PLAY GROUP TO MATRIC",
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text('ATTENDANCE RECORD',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
      child: pw.Column(
        children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text('Name: ${info['name']}')]),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(
            child: pw.Text(
                'Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}')),
        pw.Text(
            'P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}'),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(
      AttendanceController controller, List records) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }
}

// ─── _StatCard ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.count,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth > 600 ? 32 : 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth > 600 ? 14 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: screenWidth > 600 ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}

// ─── _RecordsList ─────────────────────────────────────────────────────────────

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) return const Center(child: Text("No records found"));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(r.date,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.normalizeStatus(r.status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── _ExpandableFilter ────────────────────────────────────────────────────────

class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isFilterExpanded.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Month", border: OutlineInputBorder()),
                value: controller.selectedMonth.value,
                items: AttendanceController.months
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => controller.setMonth(v!),
              ),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: "Year", border: OutlineInputBorder()),
                value: controller.selectedYear.value,
                items: controller.availableYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => controller.setYear(v!),
              ),
            ),
          ],
        ),
      );
    });
  }
} */

// ─── AttendanceScreen ─────────────────────────────────────────────────────────
/*
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 600 ? 30 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionButtons(controller: controller),
                    _ExpandableFilter(controller: controller),
                    const SizedBox(height: 16),

                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorCard(context, controller.errorMessage.value),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: "Present",
                                count: controller.presentCount,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.cancel,
                                label: "Absent",
                                count: controller.absentCount,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.event_busy,
                                label: "Late",
                                count: controller.leaveCount,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _ActionButtons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.toggleFilter,
                icon: const Icon(
                  Icons.filter_alt,
                  size: 20,
                  color: Colors.blue,
                ),
                label: const Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isGeneratingPdf.value
                      ? null
                      : () => _generatePdf(context),
                  icon: controller.isGeneratingPdf.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.picture_as_pdf,
                          size: 20,
                          color: Colors.white,
                        ),
                  label: Text(
                    controller.isGeneratingPdf.value
                        ? 'Generating...'
                        : 'Generate PDF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── PDF Generation (only this method handles saving logic) ──────────────

  Future<void> _generatePdf(BuildContext context) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;

    try {
      // ── 1. Permission: only needed on Android SDK 29 and below ───────────
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt <= 29) {
          // Android 10 and below require WRITE_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            Get.snackbar(
              "Permission Denied",
              "Please allow storage permission to save the PDF.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            return;
          }
        }
        // Android 11+ (SDK 30+): writing to /storage/emulated/0/Download
        // does NOT require any permission — the OS allows it freely.
        // Android 13+ (SDK 33+): same rule applies, no permission needed.
      }

      // ── 2. Resolve save directory ─────────────────────────────────────────
      // /storage/emulated/0/Download is the standard public Downloads folder
      // on all Android devices. path_provider's getExternalStorageDirectory()
      // returns the app-private directory, so we use the hard-coded path.
      const String folderName = 'KI Software Solutions';
      final Directory saveDir = Directory(
        '/storage/emulated/0/Download/$folderName',
      );

      // ── 3. Create folder if it does not exist ─────────────────────────────
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      // ── 4. Build the PDF document ─────────────────────────────────────────
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            _buildPdfHeader(merriweatherBold, dancingScriptBold, interBold),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      // ── 5. Build safe file name and write bytes to disk ───────────────────
      final String rawName =
          'Attendance_${info['name']}_${controller.selectedMonth.value}'
          '_${controller.selectedYear.value}.pdf';

      // Strip characters that are illegal on the Android file system
      final String safeFileName = rawName.replaceAll(
        RegExp(r'[\\/:*?"<>|\s]'),
        '_',
      );

      final File outputFile = File('${saveDir.path}/$safeFileName');
      final List<int> pdfBytes = await pdf.save();
      await outputFile.writeAsBytes(pdfBytes, flush: true);

      // ── 6. Confirm the file was actually written ──────────────────────────
      if (!await outputFile.exists()) {
        throw FileSystemException('File was not created.', outputFile.path);
      }

      // ── 7. Success snackbar with full path ────────────────────────────────
      Get.snackbar(
        " PDF Saved",
        "Saved to: Downloads/KI Software Solutions/$safeFileName",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } on FileSystemException catch (e) {
      Get.snackbar(
        "Save Failed",
        "File error: ${e.message}\nPath: ${e.path}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate PDF: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  // ─── PDF Builder Helpers ──────────────────────────────────────────────────

  pw.Widget _buildPdfHeader(
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
  ) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              "BENCHMARK",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 25,
                color: const PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
            pw.Text(
              "School of Leadership",
              style: pw.TextStyle(
                font: subTitleFont,
                fontSize: 22,
                color: const PdfColor.fromInt(0xFF0284C7),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
              ),
              child: pw.Text(
                "PLAY GROUP TO MATRIC",
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'ATTENDANCE RECORD',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text('Name: ${info['name']}')],
          ),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}',
          ),
        ),
        pw.Text(
          'P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}',
        ),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(
    AttendanceController controller,
    List records,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }
}

// ─── _StatCard ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth > 600 ? 32 : 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth > 600 ? 14 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: screenWidth > 600 ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _RecordsList ─────────────────────────────────────────────────────────────

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) {
      return const Center(child: Text("No records found"));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              r.date,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.normalizeStatus(r.status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── _ExpandableFilter ────────────────────────────────────────────────────────

class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Early return = zero height when collapsed
      if (!controller.isFilterExpanded.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Month",
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedMonth.value,
                items: AttendanceController.months
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => controller.setMonth(v!),
              ),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedYear.value,
                items: controller.availableYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => controller.setYear(v!),
              ),
            ),
          ],
        ),
      );
    });
  }
}*/

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance"), centerTitle: true),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 600 ? 30 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionButtons(controller: controller),
                    _ExpandableFilter(controller: controller),
                    const SizedBox(height: 16),

                    if (controller.errorMessage.value.isNotEmpty)
                      _buildErrorCard(context, controller.errorMessage.value),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                label: "Present",
                                count: controller.presentCount,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.cancel,
                                label: "Absent",
                                count: controller.absentCount,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.event_busy,
                                label: "Late",
                                count: controller.leaveCount,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Records",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _RecordsList(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _ActionButtons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final AttendanceController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.toggleFilter,
                icon: const Icon(
                  Icons.filter_alt,
                  size: 20,
                  color: Colors.blue,
                ),
                label: const Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final isBusy = controller.isGeneratingPdf.value;
                return AbsorbPointer(
                  absorbing: isBusy,
                  child: Opacity(
                    opacity: isBusy ? 0.5 : 1.0,
                    child: PdfHandler.buildPdfActionMenu(
                      context,
                      (isDownload) =>
                          _generatePdf(context, isDownload: isDownload),
                      isLoading: isBusy,
                      customChild: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isBusy ? Colors.grey : Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.picture_as_pdf,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                            const SizedBox(width: 8),
                            Text(
                              isBusy ? 'Generating...' : 'Generate PDF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePdf(
    BuildContext context, {
    required bool isDownload,
  }) async {
    if (controller.filteredRecords.isEmpty) {
      Get.snackbar("Error", "No records found for this month.");
      return;
    }

    controller.isGeneratingPdf.value = true;

    try {
      final pdf = pw.Document();
      final records = controller.filteredRecords;
      final info = controller.studentInfo;
      final interBold = pw.Font.helveticaBold();
      final merriweatherBold = pw.Font.timesBold();
      final dancingScriptBold = pw.Font.timesBoldItalic();
      var about = Get.find<AboutController>().aboutData.value;
      about ??= await AboutService().fetchAbout();

      Uint8List? logoBytes;

      if (about?.entityLogo != null && about!.entityLogo.isNotEmpty) {
        try {
          final response = await http.get(
            Uri.parse(about.entityLogo),
          ).timeout(const Duration(seconds: 10));
          if (response.statusCode >= 200 && response.statusCode < 300 &&
              response.bodyBytes.isNotEmpty) {
            logoBytes = response.bodyBytes;
          }
        } catch (_) {}
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          footer: (pw.Context context) => _buildPdfFooter(),
          build: (ctx) => [
            _buildPdfHeader(
              merriweatherBold,
              dancingScriptBold,
              interBold,
              about,
              logoBytes,
            ),
            pw.SizedBox(height: 20),
            _buildPdfTitle(),
            pw.SizedBox(height: 20),
            _buildPdfStudentInfo(info),
            pw.SizedBox(height: 20),
            _buildPdfSummary(controller),
            pw.SizedBox(height: 20),
            _buildPdfAttendanceTable(controller, records),
          ],
        ),
      );

      final String rawName =
          'Attendance_${info['name']}_${controller.selectedMonth.value}'
          '_${controller.selectedYear.value}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final String safeFileName = rawName.replaceAll(
        RegExp(r'[\\/:*?"<>|\s]'),
        '_',
      );

      final Uint8List pdfBytes = await pdf.save();

      await PdfHandler.handlePdfAction(
        context,
        pdfBytes,
        safeFileName,
        isDownload: isDownload,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate PDF",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      controller.isGeneratingPdf.value = false;
    }
  }

  /*
  pw.Widget _buildPdfHeader(
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
  ) {
    return pw.Center(
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              "BENCHMARK",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 25,
                color: const PdfColor.fromInt(0xFF1E3A8A),
              ),
            ),
            pw.Text(
              "School of Leadership",
              style: pw.TextStyle(
                font: subTitleFont,
                fontSize: 22,
                color: const PdfColor.fromInt(0xFF0284C7),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1E293B),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(30)),
              ),
              child: pw.Text(
                "PLAY GROUP TO MATRIC",
                style: pw.TextStyle(
                  font: boldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
*/
  pw.Widget _buildPdfHeader(
    pw.Font titleFont,
    pw.Font subTitleFont,
    pw.Font boldFont,
    AboutModel? about,
    Uint8List? logoBytes,
  ) {
    if (about == null) {
      return pw.Center(child: pw.Text("Loading..."));
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // 🖼 LOGO (FROM API)
        pw.Container(
          height: 50,
          width: 50,
          child: (logoBytes != null && logoBytes.isNotEmpty)
              ? pw.FittedBox(
                  fit: pw.BoxFit.contain,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                )
              : pw.SizedBox(),
        ),

        pw.SizedBox(width: 10),

        // 🏫 SCHOOL NAME (UNCHANGED UI)
        pw.Text(
          about.entityDesc,
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 20,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'ATTENDANCE RECORD',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Container(height: 1, width: 200, color: PdfColors.grey400),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(Map<String, String> info) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text('Name: ${info['name']}')],
          ),
          pw.SizedBox(height: 5),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(AttendanceController controller) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'Month: ${controller.selectedMonth.value} ${controller.selectedYear.value}',
          ),
        ),
        pw.Text(
          'P: ${controller.presentCount} | A: ${controller.absentCount} | L: ${controller.leaveCount}',
        ),
      ],
    );
  }

  pw.Widget _buildPdfAttendanceTable(
    AttendanceController controller,
    List records,
  ) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headers: ['Sr #', 'Date', 'Status'],
      data: List<List<dynamic>>.generate(
        records.length,
        (index) => [
          index + 1,
          records[index].date,
          controller.normalizeStatus(records[index].status),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // ⬅️ LEFT: Powered by KI Software Solutions (bold+underlined)
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: "Powered by ",
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.TextSpan(
                text: "KI Software Solutions",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),

        // ➡️ CENTER: visit our website with full URL
        pw.UrlLink(
          destination: "https://www.kisoftwaressolutions.com/",
          child: pw.Text(
            "visit our website: www.kisoftwaressolutions.com",
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),

        // ➡️ RIGHT: contact number
        pw.UrlLink(
          destination: "tel:+923197617561",
          child: pw.Text(
            "+92 3197617561",
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blue,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
      ],
    );

    /* pw.Container(
    alignment: pw.Alignment.centerLeft,
    padding: const pw.EdgeInsets.only(top: 10),
    child: pw.Text(
      'Powered by KI Software Solutions',
      style: pw.TextStyle(
        fontSize: 9,
        color: PdfColors.grey700,
      ),
    ),
  );*/
  }
}

// ─── _StatCard ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth > 600 ? 32 : 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth > 600 ? 14 : 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: screenWidth > 600 ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _RecordsList ─────────────────────────────────────────────────────────────

class _RecordsList extends StatelessWidget {
  final AttendanceController controller;
  const _RecordsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final records = controller.filteredRecords;
    if (records.isEmpty) {
      return const Center(child: Text("No records found"));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final r = records[index];
        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              r.date,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.normalizeStatus(r.status),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── _ExpandableFilter ────────────────────────────────────────────────────────

class _ExpandableFilter extends StatelessWidget {
  final AttendanceController controller;
  const _ExpandableFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isFilterExpanded.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Month",
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedMonth.value,
                items: AttendanceController.months
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => controller.setMonth(v!),
              ),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 24,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Year",
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedYear.value,
                items: controller.availableYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) => controller.setYear(v!),
              ),
            ),
          ],
        ),
      );
    });
  }
}
