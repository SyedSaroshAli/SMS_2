
// ignore_for_file: deprecated_member_use, unused_local_variable
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';
import 'package:school_management_system/utils/pdf_handler.dart';

class StudentFeeScreen extends StatelessWidget {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentFeeController>();
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fee'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllFeeData,
            ),
          ),
          PdfHandler.buildPdfActionMenu(
            context,
            (isDownload) => _exportPdf(context, controller, isDownload),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.regularFees.isEmpty &&
            controller.additionalFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            // Limits width on large screens for better readability
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _YearFilter(controller: controller),
                  const SizedBox(height: 16),
                  if (controller.errorMessage.value.isNotEmpty)
                    _ErrorBanner(message: controller.errorMessage.value),
                  _PendingFeeCard(controller: controller),
                  const SizedBox(height: 16),
                  _SummaryRow(controller: controller),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Regular Fees',
                    icon: Icons.receipt_long,
                    records: controller.regularFees,
                    emptyMessage: 'No regular fee records for this year.',
                  ),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Additional Fees',
                    icon: Icons.add_card,
                    records: controller.additionalFees,
                    emptyMessage: 'No additional fee records for this year.',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    StudentFeeController controller,
    bool isDownload,
  ) async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await PdfHandler.handlePdfAction(
        context,
        bytes,
        'Fee_Statement_${controller.studentName.value}_${controller.selectedYear.value}.pdf',
        isDownload: isDownload,
      );
    }
  }
}

// ─── Sub-Widgets (Responsive Adjustments) ───

class _YearFilter extends StatelessWidget {
  final StudentFeeController controller;
  const _YearFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Year:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                // Constraining the dropdown width on very wide screens
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.selectedYear.value,
                          isExpanded: true,
                          items: StudentFeeController.yearOptions
                              .map(
                                (y) =>
                                    DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) controller.onYearChanged(v);
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _PendingFeeCard extends StatelessWidget {
  final StudentFeeController controller;
  const _PendingFeeCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.pendingFeeMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      final isNoPending = msg.toLowerCase().contains('no pending');
      return Card(
        color: isNoPending ? Colors.green.shade50 : Colors.red.shade50,
        child: ListTile(
          leading: Icon(
            isNoPending ? Icons.check_circle : Icons.warning,
            color: isNoPending ? Colors.green : Colors.red,
          ),
          title: const Text(
            'Pending Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(msg),
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final StudentFeeController controller;
  const _SummaryRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should wrap or stay in a row based on width
        double spacing = constraints.maxWidth > 600 ? 16 : 8;

        return Obx(
          () => Row(
            children: [
              _buildSummary(
                'Regular',
                controller.totalRegularFees,
                Colors.blue,
              ),
              SizedBox(width: spacing),
              _buildSummary(
                'Additional',
                controller.totalAdditionalFees,
                Colors.purple,
              ),
              SizedBox(width: spacing),
              _buildSummary('Total', controller.grandTotal, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Rs. ${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
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

class _FeeTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FeeRecord> records;
  final String emptyMessage;

  const _FeeTable({
    required this.title,
    required this.icon,
    required this.records,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade50,
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(emptyMessage)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    // Ensures table is at least the width of the card on large screens
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: constraints.maxWidth > 600 ? 40 : 20,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Details')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: records
                          .map(
                            (r) => DataRow(
                              cells: [
                                DataCell(Text(r.month)),
                                DataCell(Text(r.details)),
                                DataCell(Text('Rs. ${r.fee}')),
                                DataCell(Text(r.feeDate)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
} */
// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';
class StudentFeeScreen extends StatelessWidget {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentFeeController>();
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fee'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllFeeData,
            ),
          ),
          PdfHandler.buildPdfActionMenu(
            context,
            (isDownload) => _exportPdf(context, controller, isDownload),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.regularFees.isEmpty &&
            controller.additionalFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _YearFilter(controller: controller),
                  const SizedBox(height: 16),
                  if (controller.errorMessage.value.isNotEmpty)
                    _ErrorBanner(message: controller.errorMessage.value),
                  _PendingFeeCard(controller: controller),
                  const SizedBox(height: 16),
                  _SummaryRow(controller: controller),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Regular Fees',
                    icon: Icons.receipt_long,
                    records: controller.regularFees,
                    emptyMessage: 'No regular fee records for this year.',
                  ),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Additional Fees',
                    icon: Icons.add_card,
                    records: controller.additionalFees,
                    emptyMessage: 'No additional fee records for this year.',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    StudentFeeController controller,
    bool isDownload,
  ) async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await PdfHandler.handlePdfAction(
        context,
        bytes,
        'Fee_Statement_${controller.studentName.value}_${controller.selectedYear.value}_${DateTime.now().millisecondsSinceEpoch}.pdf',
        isDownload: isDownload,
      );
    }
  }
}

// ─── Sub-Widgets (Responsive Adjustments) ───

class _YearFilter extends StatelessWidget {
  final StudentFeeController controller;
  const _YearFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Year:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.selectedYear.value,
                          isExpanded: true,
                          items: StudentFeeController.yearOptions
                              .map(
                                (y) =>
                                    DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) controller.onYearChanged(v);
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _PendingFeeCard extends StatelessWidget {
  final StudentFeeController controller;
  const _PendingFeeCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.pendingFeeMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      final isNoPending = msg.toLowerCase().contains('no pending');
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

      // Light mode: soft tinted background (original behaviour)
      // Dark mode: deep muted tone so text stays legible
      final cardColor = isDarkMode
          ? (isNoPending
              ? Colors.green.shade900.withOpacity(0.5)
              : Colors.red.shade900.withOpacity(0.5))
          : (isNoPending ? Colors.green.shade50 : Colors.red.shade50);

      // Icon color: brighter in dark mode for contrast, richer in light mode
      final iconColor = isDarkMode
          ? (isNoPending ? Colors.green.shade300 : Colors.red.shade300)
          : (isNoPending ? Colors.green : Colors.red);

      return Card(
        color: cardColor,
        child: ListTile(
          leading: Icon(
            isNoPending ? Icons.check_circle : Icons.warning,
            color: iconColor,
          ),
          title: Text(
            'Pending Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
          subtitle: Text(
            msg,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : null,
            ),
          ),
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final StudentFeeController controller;
  const _SummaryRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = constraints.maxWidth > 600 ? 16 : 8;

        return Obx(
          () => Row(
            children: [
              _buildSummary(
                'Regular',
                controller.totalRegularFees,
                Colors.blue,
              ),
              SizedBox(width: spacing),
              _buildSummary(
                'Additional',
                controller.totalAdditionalFees,
                Colors.purple,
              ),
              SizedBox(width: spacing),
              _buildSummary('Total', controller.grandTotal, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Rs. ${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
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

class _FeeTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FeeRecord> records;
  final String emptyMessage;

  const _FeeTable({
    required this.title,
    required this.icon,
    required this.records,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade50,
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(emptyMessage)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: constraints.maxWidth > 600 ? 40 : 20,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Details')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: records
                          .map(
                            (r) => DataRow(
                              cells: [
                                DataCell(Text(r.month)),
                                DataCell(Text(r.details)),
                                DataCell(Text('Rs. ${r.fee}')),
                                DataCell(Text(r.feeDate)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
