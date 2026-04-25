// ignore_for_file: deprecated_member_use, unused_local_variable
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/models/singleMarksheetModel.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/utils/pdf_handler.dart';

class MarksheetScreen extends StatelessWidget {
  const MarksheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarksheetController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Marksheet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: controller.refreshMarksheet,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshMarksheet,
        child: Center(
          child: Container(
            // Limits the content width on ultra-wide screens for better readability
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons Row
                  _buildActionButtons(context, controller),
                  const SizedBox(height: 16),
                  // Expandable Filter Section
                  _buildExpandableFilters(context, controller),
                  const SizedBox(height: 20),
                  // Content
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.marksheet.value == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No marksheet data available'),
                        ),
                      );
                    }

                    final marksheet = controller.marksheet.value!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Info Card
                        _buildStudentInfoCard(context, marksheet.studentInfo),
                        const SizedBox(height: 20),
                        // Subject Marks Table
                        _buildSubjectMarksTable(context, marksheet.subjects),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build action buttons row with responsive sizing
  Widget _buildActionButtons(
    BuildContext context,
    MarksheetController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                final isBusy = controller.isGeneratingPdf.value;
                return AbsorbPointer(
                  absorbing: isBusy,
                  child: Opacity(
                    opacity: isBusy ? 0.5 : 1.0,
                    child: PdfHandler.buildPdfActionMenu(
                      context,
                      (isDownload) => controller.generatePdf(
                        context,
                        isDownload: isDownload,
                      ),
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
      },
    );
  }

  /// Build expandable filters section with responsive layout
  Widget _buildExpandableFilters(
    BuildContext context,
    MarksheetController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: controller.isFilterExpanded.value
            ? Card(
                elevation: 2,
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool useRow = constraints.maxWidth > 700;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (useRow)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFilterDropdowns(
                                    controller,
                                    'Year',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterDropdowns(
                                    controller,
                                    'Task',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterDropdowns(
                                    controller,
                                    'Subject',
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildFilterDropdowns(controller, 'Year'),
                                const SizedBox(height: 12),
                                _buildFilterDropdowns(controller, 'Task'),
                                const SizedBox(height: 12),
                                _buildFilterDropdowns(controller, 'Subject'),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // Helper to choose the right dropdown logic
  Widget _buildFilterDropdowns(MarksheetController controller, String type) {
    if (type == 'Year') {
      return Obx(
        () => _buildDropdown(
          label: 'Year',
          value: controller.selectedYear.value,
          items: controller.yearOptions,
          onChanged: controller.onYearChanged,
          icon: LucideIcons.calendar,
        ),
      );
    } else if (type == 'Task') {
      return Obx(
        () => _buildDropdown(
          label: 'Task Name',
          value: controller.selectedTask.value,
          items: controller.taskOptions,
          onChanged: controller.onTaskChanged,
          icon: LucideIcons.fileCode,
        ),
      );
    } else {
      return Obx(
        () => _buildDropdown(
          label: 'Subject',
          value: controller.selectedSubject.value,
          items: controller.subjectOptions,
          onChanged: controller.onSubjectChanged,
          icon: LucideIcons.bookOpen,
        ),
      );
    }
  }

  /// Build dropdown filter with "Anti-Stretch" design
  Widget _buildDropdown({
    required String label,
    required FilterOption? value,
    required List<FilterOption> items,
    required Function(FilterOption?) onChanged,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              // The key fix for "Stretched" design: use a controlled height and clean decoration
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<FilterOption>(
                  value: value,
                  dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  isExpanded:
                      true, // Internal expansion is fine if the parent container is constrained
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      icon,
                      size: 20,
                      color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: items.map((option) {
                    return DropdownMenuItem<FilterOption>(
                      value: option,
                      child: Text(option.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build student info card with responsive layout (Stacked on mobile, Row on tablet/web)
  Widget _buildStudentInfoCard(BuildContext context, StudentInfo info) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        return Card(
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          children: [
                            _buildInfoItem('Student Name', info.name),
                            _buildInfoItem('Father Name', info.fatherName),
                            _buildInfoItem('Student ID', info.studentId),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(width: 20),
                      _buildMetric('Percentage', info.percentage, isDarkMode),
                      const SizedBox(width: 20),
                      _buildMetric(
                        'Grade',
                        info.remarksGrade,
                        isDarkMode,
                        isBadge: true,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('Student Name', info.name),
                      const SizedBox(height: 12),
                      _buildInfoItem('Father Name', info.fatherName),
                      const SizedBox(height: 12),
                      _buildInfoItem('Student ID', info.studentId),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetric(
                            'Percentage',
                            info.percentage,
                            isDarkMode,
                          ),
                          _buildMetric(
                            'Grade',
                            info.remarksGrade,
                            isDarkMode,
                            isBadge: true,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    bool isDarkMode, {
    bool isBadge = false,
  }) {
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
        isBadge
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Build subject marks table with horizontal scrolling for smaller screens
  Widget _buildSubjectMarksTable(
    BuildContext context,
    List<SubjectMark> subjects,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Subject Marks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: constraints.maxWidth > 600 ? 40 : 20,
                    headingRowColor: WidgetStateProperty.all(
                      isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                    columns: const [
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Max')),
                      DataColumn(label: Text('Pass')),
                      DataColumn(label: Text('Obtained')),
                    ],
                    rows: subjects.map((subject) {
                      return DataRow(
                        cells: [
                          DataCell(Text(subject.subjectName)),
                          DataCell(
                            Text(subject.maximumMarks.toStringAsFixed(1)),
                          ),
                          DataCell(
                            Text(subject.passingMarks.toStringAsFixed(1)),
                          ),
                          DataCell(
                            Text(
                              subject.obtainedMarks.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: subject.isPassed
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/singleMarksheetController.dart';
import 'package:school_management_system/models/singleMarksheetModel.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';
class MarksheetScreen extends StatelessWidget {
  const MarksheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarksheetController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Marksheet'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: controller.refreshMarksheet,
            tooltip: 'Refresh',
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      body: RefreshIndicator(
        onRefresh: controller.refreshMarksheet,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(screenWidth > 600 ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons Row
                  _buildActionButtons(context, controller),
                  const SizedBox(height: 16),
                  // Expandable Filter Section
                  _buildExpandableFilters(context, controller),
                  const SizedBox(height: 20),
                  // Content
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.marksheet.value == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No marksheet data available'),
                        ),
                      );
                    }

                    final marksheet = controller.marksheet.value!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Info Card
                        _buildStudentInfoCard(context, marksheet.studentInfo),
                        const SizedBox(height: 20),
                        // Subject Marks Table
                        _buildSubjectMarksTable(context, marksheet.subjects),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build action buttons row with responsive sizing
  Widget _buildActionButtons(
    BuildContext context,
    MarksheetController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                final isBusy = controller.isGeneratingPdf.value;
                return AbsorbPointer(
                  absorbing: isBusy,
                  child: Opacity(
                    opacity: isBusy ? 0.5 : 1.0,
                    child: PdfHandler.buildPdfActionMenu(
                      context,
                      (isDownload) => controller.generatePdf(
                        context,
                        isDownload: isDownload,
                      ),
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
      },
    );
  }

  /// Build expandable filters section with responsive layout
  Widget _buildExpandableFilters(
    BuildContext context,
    MarksheetController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: controller.isFilterExpanded.value
            ? Card(
                elevation: 2,
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // FIX: threshold reduced from 700 to 500 since we now
                      // only have 2 dropdowns instead of 3
                      bool useRow = constraints.maxWidth > 500;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (useRow)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFilterDropdowns(
                                    controller,
                                    'Year',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterDropdowns(
                                    controller,
                                    'Task',
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildFilterDropdowns(controller, 'Year'),
                                const SizedBox(height: 12),
                                _buildFilterDropdowns(controller, 'Task'),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // Helper to choose the right dropdown logic
  // FIX: Subject case removed entirely
  Widget _buildFilterDropdowns(MarksheetController controller, String type) {
    if (type == 'Year') {
      return Obx(
        () => _buildDropdown(
          label: 'Year',
          value: controller.selectedYear.value,
          items: controller.yearOptions,
          onChanged: controller.onYearChanged,
          icon: LucideIcons.calendar,
        ),
      );
    } else {
      return Obx(
        () => _buildDropdown(
          label: 'Task Name',
          value: controller.selectedTask.value,
          items: controller.taskOptions,
          onChanged: controller.onTaskChanged,
          icon: LucideIcons.fileCode,
        ),
      );
    }
  }

  /// Build dropdown filter with "Anti-Stretch" design
  Widget _buildDropdown({
    required String label,
    required FilterOption? value,
    required List<FilterOption> items,
    required Function(FilterOption?) onChanged,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<FilterOption>(
                  value: value,
                  dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      icon,
                      size: 20,
                      color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: items.map((option) {
                    return DropdownMenuItem<FilterOption>(
                      value: option,
                      child: Text(option.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build student info card with responsive layout (Stacked on mobile, Row on tablet/web)
  Widget _buildStudentInfoCard(BuildContext context, StudentInfo info) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        return Card(
          elevation: 2,
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          children: [
                            _buildInfoItem('Student Name', info.name),
                            _buildInfoItem('Father Name', info.fatherName),
                            _buildInfoItem('Student ID', info.studentId),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(width: 20),
                      _buildMetric('Percentage', info.percentage, isDarkMode),
                      const SizedBox(width: 20),
                      _buildMetric(
                        'Grade',
                        info.remarksGrade,
                        isDarkMode,
                        isBadge: true,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('Student Name', info.name),
                      const SizedBox(height: 12),
                      _buildInfoItem('Father Name', info.fatherName),
                      const SizedBox(height: 12),
                      _buildInfoItem('Student ID', info.studentId),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMetric(
                            'Percentage',
                            info.percentage,
                            isDarkMode,
                          ),
                          _buildMetric(
                            'Grade',
                            info.remarksGrade,
                            isDarkMode,
                            isBadge: true,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    bool isDarkMode, {
    bool isBadge = false,
  }) {
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
        isBadge
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Build subject marks table with horizontal scrolling for smaller screens
  Widget _buildSubjectMarksTable(
    BuildContext context,
    List<SubjectMark> subjects,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Subject Marks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: constraints.maxWidth > 600 ? 40 : 20,
                    headingRowColor: WidgetStateProperty.all(
                      isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                    columns: const [
                      DataColumn(label: Text('Subject')),
                      DataColumn(label: Text('Max')),
                      DataColumn(label: Text('Pass')),
                      DataColumn(label: Text('Obtained')),
                    ],
                    rows: subjects.map((subject) {
                      return DataRow(
                        cells: [
                          DataCell(Text(subject.subjectName)),
                          DataCell(
                            Text(subject.maximumMarks.toStringAsFixed(1)),
                          ),
                          DataCell(
                            Text(subject.passingMarks.toStringAsFixed(1)),
                          ),
                          DataCell(
                            Text(
                              subject.obtainedMarks.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: subject.isPassed
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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