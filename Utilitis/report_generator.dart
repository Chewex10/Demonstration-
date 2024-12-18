import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/service_request_provider.dart';

class ReportGenerator {
  Future<void> generateAndShareReport(ServiceRequest request) async {
    final pdf = pw.Document();

    // Manually format the time (TimeOfDay) to a string (HH:MM format)
    String formatTimeOfDay(TimeOfDay tod) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      final format = DateFormat.jm(); // Use 'hh:mm a' for AM/PM format, or 'HH:mm' for 24-hour format.
      return format.format(dt);
    }

    // Create the PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Service Request Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Client Name: ${request.clientName}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Service Description: ${request.serviceDescription}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Date: ${request.date}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Time: ${formatTimeOfDay(request.time)}', style: pw.TextStyle(fontSize: 18)), // Format the time manually
            pw.Text('Location: ${request.location}', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Category: ${request.category}', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            if (request.imagePath != null)
              pw.Image(
                pw.MemoryImage(File(request.imagePath!).readAsBytesSync()), // Convert image to MemoryImage
                height: 150,
                width: 150,
              ),
          ],
        ),
      ),
    );

    // Save the PDF file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/service_request_report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Share the file using share_plus
    await Share.shareFiles([file.path], text: 'Here is the service request report.');
  }
}
