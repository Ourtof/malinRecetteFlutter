import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

void registerCarrouselHtmlView() {
  if (!kIsWeb) return;
  
  ui_web.platformViewRegistry.registerViewFactory('carrousel-html-view', (
    int viewId,
  ) {
    final html.IFrameElement frame = html.IFrameElement()
      ..src = '/html/carrousel.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    return frame;
  });
}








