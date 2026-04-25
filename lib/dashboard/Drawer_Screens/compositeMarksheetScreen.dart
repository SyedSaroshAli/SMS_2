// ignore_for_file: unused_local_variable
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/compositeMarksheetController.dart';
import 'package:school_management_system/models/compositeMarksheetModel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CompositeMarksheetScreen extends StatelessWidget {
  const CompositeMarksheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompositeMarksheetController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Composite Marksheet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading transcripts...',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  size: 64,
                  color: isDarkMode ? Colors.red[300] : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadYearlyData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.yearlyMarks.isEmpty) {
          return Center(
            child: Text(
              'No transcript data available',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          );
        }

        final selected = controller.marksheetData.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ButtonsRow(controller: controller),
              const SizedBox(height: 12),
              _ExpandableFilterSection(controller: controller),
              const SizedBox(height: 12),
              if (selected == null)
                _EmptySelectionCard(isDarkMode: isDarkMode)
              else ...[
                _StudentInfoCard(info: selected.studentInfo),
                const SizedBox(height: 12),
                _CompositeMarksheetTable(marksheet: selected),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _ButtonsRow extends StatelessWidget {
  final CompositeMarksheetController controller;

  const _ButtonsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.toggleFilter,
            icon: Obx(
              () => Icon(
                controller.isFilterExpanded.value
                    ? LucideIcons.filter
                    : LucideIcons.filter,
              ),
            ),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final canGenerate = controller.selectedMarksheet.value != null;
            final isBusy = controller.isGeneratingPdf.value;
            return ElevatedButton.icon(
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(LucideIcons.fileText, size: 20),
              label: const Text('Generate PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: (!canGenerate || isBusy)
                  ? null
                  : controller.generatePdf,
            );
          }),
        ),
      ],
    );
  }
}

class _ExpandableFilterSection extends StatelessWidget {
  final CompositeMarksheetController controller;

  const _ExpandableFilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final show = controller.isFilterExpanded.value;
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: show
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (controller.availableYears.isNotEmpty)
                      Obx(
                        () => DropdownButtonFormField<String>(
                          initialValue: controller.selectedYear.value,
                          decoration: InputDecoration(
                            labelText: 'Academic Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                          ),
                          dropdownColor: isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                          items: controller.availableYears.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) controller.filterByYear(value);
                          },
                        ),
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}

class _EmptySelectionCard extends StatelessWidget {
  final bool isDarkMode;

  const _EmptySelectionCard({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isDarkMode ? 6 : 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              LucideIcons.info,
              color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No marksheet found for the selected academic year.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  final StudentInfo info;

  const _StudentInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final percentageText = '${info.percentage.toStringAsFixed(2)} %';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Card(
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoItem('Student Name', info.studentName),
                      const SizedBox(height: 12),
                      _InfoItem('Father Name', info.fatherName),
                      const SizedBox(height: 12),
                      _InfoItem('Student ID', info.studentId),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _PercentageBlock(value: percentageText),
                          ),
                          Expanded(child: _GradeBlock(value: info.grade)),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoItem('Student Name', info.studentName),
                            const SizedBox(height: 12),
                            _InfoItem('Father Name', info.fatherName),
                            const SizedBox(height: 12),
                            _InfoItem('Student ID', info.studentId),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PercentageBlock(
                              value: percentageText,
                              large: true,
                            ),
                            const SizedBox(height: 16),
                            _GradeBlock(value: info.grade),
                          ],
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}

class _PercentageBlock extends StatelessWidget {
  final String value;
  final bool large;

  const _PercentageBlock({required this.value, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Percentage',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _GradeBlock extends StatelessWidget {
  final String value;

  const _GradeBlock({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompositeMarksheetTable extends StatelessWidget {
  final CompositeMarksheetModel marksheet;

  const _CompositeMarksheetTable({required this.marksheet});

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (final subjectAssessment in marksheet.subjectAssessments) {
      final assessments = subjectAssessment.assessments;

      for (int i = 0; i < assessments.length; i++) {
        final assessment = assessments[i];
        final isFirst = i == 0;
        final isLast = i == assessments.length - 1;

        rows.add(
          DataRow(
            cells: [
              DataCell(Text(isFirst ? subjectAssessment.learningArea : '')),
              DataCell(
                Text(
                  isFirst ? subjectAssessment.subject : '',
                  style: TextStyle(
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              DataCell(Text(assessment.assessmentTitle)),
              DataCell(
                Center(child: Text(assessment.maxMarks.toStringAsFixed(0))),
              ),
              DataCell(
                Center(child: Text(assessment.passingMarks.toStringAsFixed(0))),
              ),
              DataCell(
                Center(
                  child: Text(assessment.obtainedMarks.toStringAsFixed(0)),
                ),
              ),
              DataCell(
                isLast
                    ? Center(
                        child: Text(
                          subjectAssessment.aggregateObtainedMarks
                              .toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : const Text(''),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    const columns = <DataColumn>[
      DataColumn(label: Text('Learning Area')),
      DataColumn(label: Text('Subject')),
      DataColumn(label: Text('Assessment Title')),
      DataColumn(label: Text('Max\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Passing\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Obt\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Agg.\nMarks', textAlign: TextAlign.center)),
    ];

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final columnSpacing = isMobile ? 10.0 : 20.0;
          final horizontalMargin = isMobile ? 8.0 : 16.0;
          final availableTableWidth = (constraints.maxWidth - 24).clamp(
            0.0,
            double.infinity,
          );

          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableTableWidth),
                child: DataTable(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: borderColor, width: 1),
                    bottom: BorderSide(color: borderColor, width: 1),
                  ),
                  headingRowColor: WidgetStateProperty.all(
                    isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                  horizontalMargin: horizontalMargin,
                  columnSpacing: columnSpacing,
                  headingRowHeight: 44,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 56,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  dataTextStyle: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[900],
                  ),
                  columns: columns,
                  rows: _buildRows(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/compositeMarksheetController.dart';
import 'package:school_management_system/models/compositeMarksheetModel.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';

class CompositeMarksheetScreen extends StatelessWidget {
  const CompositeMarksheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompositeMarksheetController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Composite Marksheet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: isDarkMode ? Colors.blue[300] : Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading transcripts...',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: isDarkMode ? Colors.red[300] : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadYearlyData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.yearlyMarks.isEmpty) {
          return Center(
            child: Text(
              'No transcript data available',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          );
        }

        final selected = controller.marksheetData.value;

        return Center(
          child: Container(
            // Best practice: Limit content width on web/tablets for readability
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                children: [
                  _ButtonsRow(controller: controller),
                  const SizedBox(height: 12),
                  _ExpandableFilterSection(controller: controller),
                  const SizedBox(height: 12),
                  if (selected == null)
                    _EmptySelectionCard(isDarkMode: isDarkMode)
                  else ...[
                    _StudentInfoCard(info: selected.studentInfo),
                    const SizedBox(height: 12),
                    _CompositeMarksheetTable(marksheet: selected),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ButtonsRow extends StatelessWidget {
  final CompositeMarksheetController controller;

  const _ButtonsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.toggleFilter,
            icon: const Icon(LucideIcons.filter, size: 20),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final canGenerate = controller.selectedMarksheet.value != null;
            final isBusy = controller.isGeneratingPdf.value;
            return AbsorbPointer(
              absorbing: !canGenerate || isBusy,
              child: Opacity(
                opacity: (!canGenerate || isBusy) ? 0.5 : 1.0,
                child: PdfHandler.buildPdfActionMenu(
                  context,
                  (isDownload) =>
                      controller.generatePdf(context, isDownload: isDownload),
                  isLoading: isBusy,
                  customChild: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
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
                                LucideIcons.fileText,
                                size: 20,
                                color: Colors.white,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          isBusy ? 'Generating...' : 'Generate PDF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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
  }
}

class _ExpandableFilterSection extends StatelessWidget {
  final CompositeMarksheetController controller;

  const _ExpandableFilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final show = controller.isFilterExpanded.value;
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: show
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.availableYears.isNotEmpty)
                      ConstrainedBox(
                        // Prevents dropdown from being too wide on Desktop
                        constraints: BoxConstraints(
                          maxWidth: screenWidth > 600 ? 400 : double.infinity,
                        ),
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.selectedYear.value,
                            decoration: InputDecoration(
                              labelText: 'Academic Year',
                              prefixIcon: const Icon(LucideIcons.calendar),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                            ),
                            dropdownColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                            items: controller.availableYears.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) controller.filterByYear(value);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}

class _EmptySelectionCard extends StatelessWidget {
  final bool isDarkMode;

  const _EmptySelectionCard({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isDarkMode ? 6 : 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              LucideIcons.info,
              color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No marksheet found for the selected academic year.',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentInfoCard extends StatelessWidget {
  final StudentInfo info;

  const _StudentInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final percentageText = '${info.percentage.toStringAsFixed(2)} %';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return Card(
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoItem('Student Name', info.studentName),
                      const SizedBox(height: 12),
                      _InfoItem('Father Name', info.fatherName),
                      const SizedBox(height: 12),
                      _InfoItem('Student ID', info.studentId),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _PercentageBlock(value: percentageText),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _GradeBlock(value: info.grade)),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: 200,
                              child: _InfoItem(
                                'Student Name',
                                info.studentName,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: _InfoItem('Father Name', info.fatherName),
                            ),
                            SizedBox(
                              width: 150,
                              child: _InfoItem('Student ID', info.studentId),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 32),
                      IntrinsicWidth(
                        child: Column(
                          children: [
                            _PercentageBlock(
                              value: percentageText,
                              large: true,
                            ),
                            const SizedBox(height: 12),
                            _GradeBlock(value: info.grade),
                          ],
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

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          softWrap: true,
        ),
      ],
    );
  }
}

class _PercentageBlock extends StatelessWidget {
  final String value;
  final bool large;

  const _PercentageBlock({required this.value, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Percentage',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: large ? 26 : 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradeBlock extends StatelessWidget {
  final String value;

  const _GradeBlock({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompositeMarksheetTable extends StatelessWidget {
  final CompositeMarksheetModel marksheet;

  const _CompositeMarksheetTable({required this.marksheet});

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];

    for (final subjectAssessment in marksheet.subjectAssessments) {
      final assessments = subjectAssessment.assessments;

      for (int i = 0; i < assessments.length; i++) {
        final assessment = assessments[i];
        final isFirst = i == 0;
        final isLast = i == assessments.length - 1;

        rows.add(
          DataRow(
            cells: [
              DataCell(Text(isFirst ? subjectAssessment.learningArea : '')),
              DataCell(
                Text(
                  isFirst ? subjectAssessment.subject : '',
                  style: TextStyle(
                    fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              DataCell(Text(assessment.assessmentTitle)),
              DataCell(
                Center(child: Text(assessment.maxMarks.toStringAsFixed(0))),
              ),
              DataCell(
                Center(child: Text(assessment.passingMarks.toStringAsFixed(0))),
              ),
              DataCell(
                Center(
                  child: Text(assessment.obtainedMarks.toStringAsFixed(0)),
                ),
              ),
              DataCell(
                isLast
                    ? Center(
                        child: Text(
                          subjectAssessment.aggregateObtainedMarks
                              .toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : const Text(''),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    const columns = <DataColumn>[
      DataColumn(label: Text('Learning Area')),
      DataColumn(label: Text('Subject')),
      DataColumn(label: Text('Assessment Title')),
      DataColumn(label: Text('Max\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Passing\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Obt\nMarks', textAlign: TextAlign.center)),
      DataColumn(label: Text('Agg.\nMarks', textAlign: TextAlign.center)),
    ];

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final columnSpacing = isMobile ? 12.0 : 24.0;
          final horizontalMargin = isMobile ? 8.0 : 16.0;

          return Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth - 16,
                ),
                child: DataTable(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: borderColor,
                      width: 0.5,
                    ),
                    bottom: BorderSide(color: borderColor, width: 0.5),
                  ),
                  headingRowColor: WidgetStateProperty.all(
                    isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  ),
                  horizontalMargin: horizontalMargin,
                  columnSpacing: columnSpacing,
                  headingRowHeight: 56,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  dataTextStyle: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[200] : Colors.grey[900],
                  ),
                  columns: columns,
                  rows: _buildRows(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
