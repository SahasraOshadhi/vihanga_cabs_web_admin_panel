import 'package:flutter/material.dart';

Widget iframeView(String pdfUrl) {
  // Fallback for non-web platforms
  return Center(child: Text("This feature is not available on this platform."));
}
