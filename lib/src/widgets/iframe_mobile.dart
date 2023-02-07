import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/src/replaced_element.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart' as dom;
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();

  IframeContentElement({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required dom.Element node,
    required this.navigationDelegate,
  }) : super(name: name, style: Style(), node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    final sandboxMode = attributes["sandbox"];
    return Container(
      width: width ?? (height ?? 150) * 2,
      height: height ?? (width ?? 300) / 2,
      child: CustomWebViewWidget(
        isSandboxMode: sandboxMode == null || sandboxMode == "allow-scripts",
        key: key,
        url: src ?? '',
        navigationDelegate: navigationDelegate,
      ),
    );
  }
}

class CustomWebViewWidget extends StatefulWidget {
  final String url;
  final bool isSandboxMode;
  final NavigationDelegate? navigationDelegate;

  const CustomWebViewWidget({
    required this.url,
    required this.isSandboxMode,
    required Key key,
    this.navigationDelegate,
  }) : super(key: key);

  @override
  State<CustomWebViewWidget> createState() => _CustomWebViewWidgetState();
}

class _CustomWebViewWidgetState extends State<CustomWebViewWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(widget.isSandboxMode
          ? JavaScriptMode.unrestricted
          : JavaScriptMode.disabled)
      ..loadRequest(Uri.parse(widget.url));

    if (widget.navigationDelegate != null) {
      controller..setNavigationDelegate(widget.navigationDelegate!);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _controller,
      key: widget.key,
      gestureRecognizers: {
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        )
      },
    );
  }
}
