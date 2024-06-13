import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewDialog extends StatelessWidget {
  final String pdfUrl;

  PdfViewDialog({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: Text('View PDF'),
          actions: [
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () async {
                if (await canLaunch(pdfUrl)) {
                  await launch(pdfUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not download PDF')),
                  );
                }
              },
            ),
          ],
        ),
        body: PdfViewWidget(pdfUrl: pdfUrl),
      ),
    );
  }
}

class PdfViewWidget extends StatelessWidget {
  final String pdfUrl;

  PdfViewWidget({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _downloadPdf(pdfUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error loading PDF'));
          } else {
            return SfPdfViewer.memory(
              snapshot.data!,
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Uint8List> _downloadPdf(String url) async {
    try {
      final response = await Dio().get<Uint8List>(url, options: Options(responseType: ResponseType.bytes));
      return response.data!;
    } catch (e) {
      throw Exception('Error downloading PDF: $e');
    }
  }
}
