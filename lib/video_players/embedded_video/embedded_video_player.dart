import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContentWidget extends StatefulWidget {
  final WebViewController webViewController;
  const WebViewContentWidget({super.key, required this.webViewController});

  @override
  State<WebViewContentWidget> createState() => _WebViewContentWidgetState();
}

class _WebViewContentWidgetState extends State<WebViewContentWidget> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: context.width(),
      height: context.height() * 0.3,
      child: WebViewWidget(controller: widget.webViewController),
    );
  }
}