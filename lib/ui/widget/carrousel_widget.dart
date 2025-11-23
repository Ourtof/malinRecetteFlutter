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
        ..style.height = '100%';
      return frame;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      child: const HtmlElementView(viewType: 'carrousel-html-view'),
    );
  }
}
