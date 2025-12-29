import 'package:flutter/widgets.dart';
// Import conditionnel : utilise web_helper_web.dart sur le web, sinon utilise le stub
import 'web_helper_web.dart' if (dart.library.io) 'web_helper_stub.dart' as web_helper;

class CarrouselWidget extends StatelessWidget {
  CarrouselWidget({super.key}) {
    web_helper.registerCarrouselHtmlView();
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
