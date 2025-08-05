import 'package:flutter/widgets.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

class CarrouselWidget extends StatelessWidget {
  CarrouselWidget({super.key}) {
    _registerCarrouselHtmlView();
  }

  static void _registerCarrouselHtmlView() {
    ui_web.platformViewRegistry.registerViewFactory('carrousel-html-view', (
      int viewId,
    ) {
      final web.HTMLIFrameElement frame = web.HTMLIFrameElement()
        ..src = '/html/carrousel.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100vh';
      return frame;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 600,
      width: double.infinity,
      child: HtmlElementView(viewType: 'carrousel-html-view'),
    );
  }
}
