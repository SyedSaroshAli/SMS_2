import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/about_controller.dart';
import 'package:school_management_system/services/about_service.dart';
import 'package:school_management_system/models/student_fee_models.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StudentFeeController extends GetxController {
  // ─── State ────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<FeeRecord> regularFees = <FeeRecord>[].obs;
  final RxList<FeeRecord> additionalFees = <FeeRecord>[].obs;
  final RxString pendingFeeMessage = ''.obs;

  final RxString studentName = ''.obs;
  final RxString studentId = ''.obs;

  final RxString selectedYear = ''.obs;
  static final List<String> yearOptions = [
    DateTime.now().year.toString(),
    (DateTime.now().year - 1).toString(),
    (DateTime.now().year - 2).toString(),
  ];

  final _api = ApiService();
  final _auth = AuthService();

  
  double get totalRegularFees => regularFees.fold(0.0, (sum, r) => sum + r.fee);
  double get totalAdditionalFees =>
      additionalFees.fold(0.0, (sum, r) => sum + r.fee);
  double get grandTotal => totalRegularFees + totalAdditionalFees;

 
  @override
  void onInit() {
    super.onInit();
    selectedYear.value = yearOptions.first;
    _loadStudentInfo();
    fetchAllFeeData();
  }

  Future<void> _loadStudentInfo() async {
    studentId.value = await _auth.getStudentId() ?? '';
    studentName.value = await _auth.getStudentName() ?? '';
  }

  Future<void> fetchAllFeeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (studentId.value.isEmpty) {
        await _loadStudentInfo();
      }

      await Future.wait([
        _fetchRegularFees(),
        _fetchAdditionalFees(),
        _fetchPendingFees(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load fee data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  

  Future<void> _fetchRegularFees() async {
    try {
      final response = await _api.get(
        '/StudentFee/Get-StudentFees',
        queryParams: {'Year': selectedYear.value},
      );

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] is List) {
        final data = (response['data'] as List)
            .cast<Map<String, dynamic>>()
            .map((json) => FeeRecord.fromJson(json))
            .toList();

        final sid = studentId.value;
        regularFees.value = sid.isNotEmpty 
            ? data.where((r) => r.studentId.toString() == sid).toList()
            : data;
      } else {
        regularFees.clear();
      }
    } catch (e) {
      regularFees.clear();
    }
  }

  Future<void> _fetchAdditionalFees() async {
    try {
      final response = await _api.get(
        '/StudentFee/Get-StudentFeeAdditionals',
        queryParams: {'Year': selectedYear.value},
      );

      if (response is Map<String, dynamic> &&
          response['success'] == true &&
          response['data'] is List) {
        final data = (response['data'] as List)
            .cast<Map<String, dynamic>>()
            .map((json) => FeeRecord.fromJson(json))
            .toList();

        final sid = studentId.value;
        additionalFees.value = sid.isNotEmpty 
            ? data.where((r) => r.studentId.toString() == sid).toList()
            : data;
      } else {
        additionalFees.clear();
      }
    } catch (e) {
      additionalFees.clear();
    }
  }

  Future<void> _fetchPendingFees() async {
    try {
      final sid = studentId.value;
      if (sid.isEmpty) return;

      final response = await _api.get(
        '/PendingFee/Get-PendingFee-Tasks',
        queryParams: {'StudentId': sid, 'Year': selectedYear.value},
      );

      if (response is String) {
        pendingFeeMessage.value = response.trim().replaceAll('"', '');
      } else {
        pendingFeeMessage.value = 'No Pending Fee';
      }
    } catch (e) {
      pendingFeeMessage.value = 'No Pending Fee';
    }
  }

  void onYearChanged(String year) {
    selectedYear.value = year;
    fetchAllFeeData();
  }

  // ─── Dashboard Helper (FIXES THE COMPILER ERROR) ───────

  FeeRecord? getCurrentMonthFee() {
    final now = DateTime.now();
    final currentMonthFull = DateFormat('MMMM').format(now).toLowerCase();
    final currentYear = now.year.toString();

    try {
      return regularFees.firstWhere(
        (fee) =>
            normalizeMonth(fee.month) == currentMonthFull &&
            fee.year == currentYear,
      );
    } catch (e) {
      return null;
    }
  }

  String normalizeMonth(String month) {
    month = month.trim().toLowerCase();
    Map<String, String> monthMap = {
      "jan": "january", "feb": "february", "mar": "march", "apr": "april",
      "may": "may", "jun": "june", "jul": "july", "aug": "august",
      "sep": "september", "oct": "october", "nov": "november", "dec": "december"
    };
    if (month.length <= 3) return monthMap[month] ?? month;
    return month;
  }

  // ─── PDF Generation ────────────────────────────────────

  Future<Uint8List?> generatePdf() async {
    if (regularFees.isEmpty && additionalFees.isEmpty) {
      Get.snackbar('Info', 'No fee records to generate PDF.');
      return null;
    }

    final doc = pw.Document();
    final titleFont = pw.Font.helveticaBold();
    pw.ImageProvider? logoImage;

try {
  var about = Get.find<AboutController>().aboutData.value;
  about ??= await AboutService().fetchAbout();

  if (about?.entityLogo != null && about!.entityLogo!.isNotEmpty) {
    logoImage = await networkImage(about.entityLogo!);
  }
} catch (_) {}
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
       header: (_) => _pdfHeader(titleFont, logoImage),
        footer: (_) => _pdfFooter(),
        build: (_) => [
          pw.SizedBox(height: 16),
          _pdfStudentInfo(),
          pw.SizedBox(height: 20),
          if (regularFees.isNotEmpty) ...[
            pw.Text('Monthly / Regular Fees', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _pdfFeeTable(regularFees),
            pw.SizedBox(height: 8),
            _pdfTotalRow('Total Regular Fees', totalRegularFees),
            pw.SizedBox(height: 20),
          ],
          if (additionalFees.isNotEmpty) ...[
            pw.Text('Additional Fees', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _pdfFeeTable(additionalFees),
            pw.SizedBox(height: 8),
            _pdfTotalRow('Total Additional Fees', totalAdditionalFees),
            pw.SizedBox(height: 20),
          ],
          pw.Divider(),
          _pdfTotalRow('Grand Total', grandTotal, isGrandTotal: true),
        ],
      ),
    );

    return doc.save();
  }
/*
  pw.Widget _pdfHeader(pw.Font titleFont) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text("BENCHMARK", style: pw.TextStyle(font: titleFont, fontSize: 26, color: PdfColors.blue900)),
              pw.Text("School of Leadership", style: pw.TextStyle(fontSize: 22, color: PdfColors.blue700)),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: const pw.BoxDecoration(color: PdfColors.grey900, borderRadius: pw.BorderRadius.all(pw.Radius.circular(30))),
                child: pw.Text("PLAY GROUP TO MATRIC", style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Text("Fee Statement for year ${selectedYear.value}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.Divider(thickness: 1, color: PdfColors.grey400),
      ],
    );
  }
*/
pw.Widget _pdfHeader(pw.Font titleFont, pw.ImageProvider? logoImage) {
  final about = Get.find<AboutController>().aboutData.value;

  return pw.Column(
    children: [
      pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [

            // 🖼 LOGO (bigger, centered, no border)
            if (logoImage != null)
              pw.Container(
                height: 80, // increased size
                width: 80,
                child: pw.FittedBox(
                  fit: pw.BoxFit.contain,
                  child: pw.Image(logoImage),
                ),
              ),

            pw.SizedBox(height: 8),

            // 🏫 SCHOOL NAME FROM API (center, black)
            pw.Text(
              about?.entityDesc ?? '',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 15),

      pw.Text(
        "Fee Statement for year ${selectedYear.value}",
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
      ),

      pw.Divider(thickness: 1, color: PdfColors.grey400),
    ],
  );
}
  pw.Widget _pdfStudentInfo() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Student Name: ${studentName.value}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("Student ID: ${studentId.value}"),
          ],
        ),
        pw.Text("Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}"),
      ],
    );
  }

  pw.Widget _pdfFeeTable(List<FeeRecord> records) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 25,
      headers: ['Month', 'Details', 'Amount', 'Date', 'Slip No'],
      data: records.map((r) => [r.month, r.details, 'Rs. ${r.fee.toStringAsFixed(0)}', r.feeDate, r.slipNo.toString()]).toList(),
    );
  }

  pw.Widget _pdfTotalRow(String label, double total, {bool isGrandTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: isGrandTotal ? 14 : 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 20),
        pw.Text("Rs. ${total.toStringAsFixed(0)}", style: pw.TextStyle(fontSize: isGrandTotal ? 14 : 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _pdfFooter() {
    return pw.Column(
      children: [
         pw.Row(
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
      ),
        pw.Divider(color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("System Generated Statement", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          
           
          ],
        ),
      ],
    );
  }
}