import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;

Widget iframeView(String pdfUrl) {
  // Registering the view type
  ui.platformViewRegistry.registerViewFactory('iframeElement', (int viewId) {
    final iframe = html.IFrameElement()
      ..src = pdfUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return iframe;
  });

  // Creating the HtmlElementView
  return HtmlElementView(viewType: 'iframeElement');
}
