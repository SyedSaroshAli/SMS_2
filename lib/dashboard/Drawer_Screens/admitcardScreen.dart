import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:google_fonts/google_fonts.dart';
import 'package:school_management_system/controllers/about_controller.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import 'package:school_management_system/utils/pdf_handler.dart';
import 'package:school_management_system/utils/app_footer.dart';

class AdmitCardScreen extends StatelessWidget {
  const AdmitCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmitCardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admit Card"),
        actions: [
          Obx(
            () => controller.admitCard.value == null
                ? const SizedBox()
                : PdfHandler.buildPdfActionMenu(
                    context,
                    (isDownload) => _generatePdf(
                      context,
                      controller,
                      isDownload: isDownload,
                    ),
                    isLoading: controller.isGeneratingPdf.value,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.admitCard.value;
        if (data == null) {
          return const Center(child: Text("No Data"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _buildAdmitCardUI(data),
            ),
          ),
        );
      }),
    );
  }

  // --- UI PART ---

  Widget _buildAdmitCardUI(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildHeader(data),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTable(data),
          ),
          const SizedBox(height: 33),
          _buildSignatures(),
        ],
      ),
    );
  }
/*
  Widget _buildHeader(AdmitCardModel data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/benchmark-logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 50),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(
                  "BENCHMARK",
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "School of Leadership",
                  style: GoogleFonts.dancingScript(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "PLAY GROUP TO MATRIC",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${data.examTitle} ${data.year}".toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } */
 Widget _buildHeader(AdmitCardModel data) {
  final about = Get.find<AboutController>().aboutData.value;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    child: Column(
      children: [

        // 🖼 LOGO CENTER (NO CIRCLE, NO BORDER)
        (about?.entityLogo != null && about!.entityLogo!.isNotEmpty)
            ? Image.network(
                about.entityLogo!,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school, size: 50),
              )
            : const Icon(Icons.school, size: 50),

       

        // 🏫 SCHOOL NAME (FROM API)
        /*
        Text(
          (about?.entityDesc ?? "SCHOOL NAME").toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E3A8A),
            letterSpacing: 1.2,
          ),
        ),
*/
        const SizedBox(height: 4),

        // 📌 EXAM TITLE + YEAR (UNCHANGED)
        Text(
          "${data.examTitle} ${data.year}".toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
/*
  Widget _buildTable(AdmitCardModel data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 18,
                  child: Column(
                    children: [
                      _gridRow([
                        _gridCell(5, "Student's Name", isBold: true),
                        _gridCell(
                          5,
                          data.studentName,
                          isCenter: true,
                          borderRight: true,
                        ),
                        /*
                        _gridCell(5, "Father's Name", isBold: true),
                        _gridCell(
                          5,
                          data.fatherName,
                          isCenter: true,
                          borderRight: false,
                        ), */
                      ]),

                       _gridRow([
                        _gridCell(6, "Father's Name", isBold: true),
                        _gridCell(12, data.fatherName, isCenter: true, borderRight: false),
                      ]), 
                      _gridRow([
                        _gridCell(5, "Class", isBold: true),
                        _gridCell(5, data.classId.toString(), isCenter: true),
                        _gridCell(5, "Section", isBold: true),
                        _gridCell(
                          5,
                          data.section,
                          isCenter: true,
                          borderRight: false,
                        ),
                        /* _gridCell(5, "Seat No.", isBold: true),
                _gridCell(3, data.seatNo.toString(), isCenter: true, borderRight: false),
*/
                      ], borderBottom: false),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child:
                          (data.photoUrl != null && data.photoUrl!.isNotEmpty)
                          ? Image.network(
                              data.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 32.5,
                                    color: Colors.grey,
                                  ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 32.5,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gridCell(5, "Class Desc", isBold: true),
                _gridCell(5, data.className, isCenter: true),
                _gridCell(5, "G.R No.", isBold: true),
                _gridCell(4, data.grNo, isCenter: true),
                _gridCell(4, "Seat No.", isBold: true),
                _gridCell(
                  2,
                  data.seatNo.toString(),
                  isCenter: true,
                  borderRight: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
    return Container(
      decoration: borderBottom
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  Widget _gridCell(
    int flex,
    String text, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: borderRight
            ? const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.black, width: 1),
                ),
              )
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        alignment: isCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 7,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
*/
Widget _buildTable(AdmitCardModel data) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 1.0),
    ),
    child: Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT SIDE TABLE
              Expanded(
                flex: 18,
                child: Column(
                  children: [
                    // Student Name
                    _gridRow([
                      _gridCell(4, "Student's Name", isBold: true),
                      _gridCell(8, data.studentName, isCenter: true,showRightBorder: false),
                    ]),

                    // Father's Name
                    _gridRow([
                      _gridCell(4, "Father's Name", isBold: true),
                      _gridCell(8, data.fatherName, isCenter: true,showRightBorder: false),
                    ]),

                    // Class + Section
                    _gridRow([
                      _gridCell(4, "Class", isBold: true),
                      _gridCell(3, data.classId.toString(), isCenter: true),
                      _gridCell(2, "Section", isBold: true),
                      _gridCell(4, data.section, isCenter: true,showRightBorder: false),
                    ]),
                  /*
                    // Admission + GR + Seat
                    _gridRow([
                      _gridCell(3, "Class Desc", isBold: true),
                      _gridCell(3, data.className, isCenter: true),
                      _gridCell(2, "G.R No.", isBold: true),
                      _gridCell(2, data.grNo, isCenter: true),
                      _gridCell(2, "Seat No.", isBold: true),
                      _gridCell(2, data.seatNo.toString(), isCenter: true),
                    ], borderBottom: false), */
                  ],
                ),
              ),

              // PHOTO SECTION
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.black, width: 1),
                      bottom: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Center(
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: (data.photoUrl != null &&
                              data.photoUrl!.isNotEmpty)
                          ? Image.network(
                              data.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        _gridRow([
                      _gridCell(3, "Class Desc", isBold: true),
                      _gridCell(3, data.className, isCenter: true),
                      _gridCell(2, "G.R No.", isBold: true),
                      _gridCell(2, data.grNo, isCenter: true),
                      _gridCell(2, "Seat No.", isBold: true),
                      _gridCell(2, data.seatNo.toString(), isCenter: true,showRightBorder: false),
                    ], borderBottom: false),
      ],
    ),
  );
}

Widget _gridRow(List<Widget> cells, {bool borderBottom = true}) {
  return Container(
    decoration: borderBottom
        ? const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          )
        : null,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    ),
  );
}

Widget _gridCell(
  int flex,
  String text, {
  bool isCenter = false,
  bool isBold = false,
  bool showRightBorder = true,
}) {
  return Expanded(
    flex: flex,
    child: Container(
      decoration: BoxDecoration(
      border: showRightBorder
            ? const Border(
                right: BorderSide(color: Colors.black, width: 1),
                
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          fontSize: 8,
          color: Colors.black,
        ),
      ),
    ),
  );
}
  Widget _buildSignatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox("Signature of Controller"),
          _signatureBox("Signature of Class Teacher"),
        ],
      ),
    );
  }

  Widget _signatureBox(String title) {
    return Column(
      children: [
        Container(width: 60, height: 1, color: Colors.black),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 6,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // --- PDF PART ---

Future<void> _generatePdf(
  BuildContext context,
  AdmitCardController controller, {
  required bool isDownload,
}) async {
  controller.isGeneratingPdf.value = true;

  try {
    final data = controller.admitCard.value!;
    final pdf = pw.Document();

    // ✅ FIXED FONTS (NO ERRORS)
    final interBold = pw.Font.helveticaBold();
    final interRegular = pw.Font.helvetica();
    final titleFont = pw.Font.helveticaBold();

    // ✅ LOGO FROM API
    final about = Get.find<AboutController>().aboutData.value;
    pw.MemoryImage? logoImage;

    try {
      if (about?.entityLogo != null && about!.entityLogo!.isNotEmpty) {
        final response = await NetworkAssetBundle(
          Uri.parse(about.entityLogo!),
        ).load("");

        logoImage = pw.MemoryImage(response.buffer.asUint8List());
      }
    } catch (_) {}

    // ✅ STUDENT PHOTO
    pw.MemoryImage? studentPhoto;
    if (data.photoUrl != null && data.photoUrl!.isNotEmpty) {
      try {
        final responseData = await NetworkAssetBundle(
          Uri.parse(data.photoUrl!),
        ).load("");

        studentPhoto = pw.MemoryImage(responseData.buffer.asUint8List());
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.black, width: 2),
            ),
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              children: [
                _buildPdfHeader(
                  data,
                  logoImage,
                  titleFont
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPdfTable(
                    data,
                    interBold,
                    interRegular,
                    studentPhoto,
                  ),
                ),
                pw.SizedBox(height: 60),
                _buildPdfSignatures(interBold),
              ],
            ),
          );
        },
      ),
    );

    await PdfHandler.handlePdfAction(
      context,
      await pdf.save(),
      "${data.studentName}_AdmitCard_${DateTime.now().millisecondsSinceEpoch}.pdf",
      isDownload: isDownload,
    );
  } finally {
    controller.isGeneratingPdf.value = false;
  }
}

pw.Widget _buildPdfHeader(
  AdmitCardModel data,
  pw.MemoryImage? logo,
  pw.Font titleFont,
) {
  final about = Get.find<AboutController>().aboutData.value;

  return pw.Padding(
    padding: const pw.EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: pw.Column(
      children: [

        // 🖼 LOGO CENTER
        pw.Center(
          child: pw.Container(
            width: 140,
            height: 140,
            child: logo != null
                ? pw.Image(
                    logo,
                    fit: pw.BoxFit.contain,
                  )
                : pw.SizedBox(),
          ),
        ),

        pw.SizedBox(height: 10),

      
        pw.SizedBox(height: 15),

        // 📌 EXAM TITLE + YEAR (UNCHANGED)
        pw.Text(
          "${data.examTitle} ${data.year}".toUpperCase(),
          style: pw.TextStyle(
            font: titleFont,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),

        pw.SizedBox(height: 10),
      ],
    ),
  );
}
  pw.Widget _buildPdfTable(
    AdmitCardModel data,
    pw.Font boldFont,
    pw.Font regFont,
    pw.MemoryImage? studentPhoto,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 18,
                child: pw.Column(
                  children: [
                    
                    _pdfGridRow([
                      _pdfGridCell(5, "Student's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        5,
                        data.studentName,
                        boldFont,
                        isCenter: true,
                        borderRight: true,
                      ),
                      _pdfGridCell(5, "Father's Name", boldFont, isBold: true),
                      _pdfGridCell(
                        5,
                        data.fatherName,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ]),

                    _pdfGridRow([
                      _pdfGridCell(5, "Class", boldFont, isBold: true),
                      _pdfGridCell(
                        5,
                        data.classId.toString(),
                        boldFont,
                        isCenter: true,
                      ),
                      _pdfGridCell(5, "Section", boldFont, isBold: true),
                      _pdfGridCell(
                        5,
                        data.section,
                        boldFont,
                        isCenter: true,
                        borderRight: false,
                      ),
                    ], borderBottom: false),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  height: 69,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.black, width: 1),
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: studentPhoto != null
                        ? pw.Image(studentPhoto, fit: pw.BoxFit.cover)
                        : pw.Text(
                            "PHOTO",
                            style: pw.TextStyle(font: regFont, fontSize: 10),
                          ),
                  ),
                ),
              ),
            ],
          ),
          pw.Container(height: 1, color: PdfColors.black),
          pw.Row(
            children: [
              _pdfGridCell(6, "Class Desc", boldFont, isBold: true),
              _pdfGridCell(6, data.className, boldFont, isCenter: true),
              _pdfGridCell(5, "G.R No.", boldFont, isBold: true),
              _pdfGridCell(4, data.grNo, boldFont, isCenter: true),
              _pdfGridCell(4, "Seat No.", boldFont, isBold: true),
              _pdfGridCell(
                2,
                data.seatNo.toString(),
                boldFont,
                isCenter: true,
                borderRight: false,
              ),
            ],
          ),
        ],
      ),
    );
  } 
 
  pw.Widget _pdfGridRow(List<pw.Widget> cells, {bool borderBottom = true}) {
    return pw.Container(
      decoration: borderBottom
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.black, width: 1),
              ),
            )
          : null,
      child: pw.Row(children: cells),
    );
  }

  pw.Widget _pdfGridCell(
    int flex,
    String text,
    pw.Font font, {
    bool borderRight = true,
    bool isCenter = false,
    bool isBold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        decoration: borderRight
            ? const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              )
            : null,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.black),
        ),
      ),
    );
  }


pw.Widget _buildPdfSignatures(pw.Font font) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 40),
    child: pw.Column(
      children: [
         pw.SizedBox(height: 20),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _pdfSignatureBox("Signature of Controller", font),
            _pdfSignatureBox("Signature of Class Teacher", font),
          ],
        ),
        pw.SizedBox(height: 70),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // ⬅️ LEFT: "Powered by KI Software Solutions" (KI Software Solutions bold+underlined)
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "Powered by ",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                  pw.TextSpan(
                    text: "KI Software Solutions",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            // ➡️ CENTER: visit our website: www.kisoftwaressolutions.com
            pw.UrlLink(
              destination: "https://www.kisoftwaressolutions.com/",
              child: pw.Text(
                "visit our website: www.kisoftwaressolutions.com",
                style: pw.TextStyle(
                  font: font,
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
                  font: font,
                  fontSize: 10,
                  color: PdfColors.blue,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        
      ],
    ),
  );
}
  pw.Widget _pdfSignatureBox(String title, pw.Font font) {
    return pw.Column(
      children: [
        pw.Container(width: 160, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
  }
}
