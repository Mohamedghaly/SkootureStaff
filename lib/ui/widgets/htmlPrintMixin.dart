import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

mixin HtmlPrintMixin<T extends StatefulWidget> on State<T> {
  String _printFileUrl = '';
  String _printJobName = '';

  // Guards against double-fire when parent setState rebuilds the widget tree
  // while a print job is already in flight.
  bool _printDispatched = false;

  Future<void> schedulePrint({
    required String html,
    required String fileName,
    required String jobName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName.html');
    await file.writeAsString(html);
    if (!mounted) return;
    setState(() {
      _printJobName = jobName;
      _printFileUrl = file.uri.toString();
      _printDispatched = false;
    });
  }

  Widget buildHiddenPrintWebView({
    VoidCallback? onPrintDispatched,
    bool useWideViewPort = false,
  }) {
    if (_printFileUrl.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: InAppWebView(
        // Stable key prevents Flutter from tearing down and recreating the
        // WebView on parent setState calls, which would re-fire onLoadStop.
        key: const ValueKey('_html_print_webview'),
        initialUrlRequest: URLRequest(url: WebUri(_printFileUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useHybridComposition: true,
          allowFileAccess: true,
          allowFileAccessFromFileURLs: true,
          useWideViewPort: useWideViewPort,
          loadWithOverviewMode: useWideViewPort,
        ),
        onLoadStop: (controller, url) {
          if (_printFileUrl.isEmpty || _printDispatched) return;
          _printDispatched = true;
          _executePrint(
            controller: controller,
            onPrintDispatched: onPrintDispatched,
          );
        },
      ),
    );
  }

  Future<void> _executePrint({
    required InAppWebViewController controller,
    VoidCallback? onPrintDispatched,
  }) async {
    // Initial delay — allows the Android rendering pipeline to complete its
    // first paint. 500 ms is not enough on cold-start; 1 s covers it reliably.
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted || _printFileUrl.isEmpty) {
      _printDispatched = false;
      return;
    }

    // Poll document.readyState so that script-driven layouts (e.g. charts,
    // CSS @font-face) are fully applied before the print adapter captures the
    // page. Gives up after 5 × 300 ms = 1.5 s of extra wait.
    try {
      for (int i = 0; i < 5; i++) {
        final result = await controller.evaluateJavascript(
          source: 'document.readyState',
        );
        final ready = result?.toString().replaceAll('"', '') ?? '';
        if (ready == 'complete') break;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (_) {
      // JS eval failure is non-fatal — proceed with print.
    }

    if (!mounted || _printFileUrl.isEmpty) {
      _printDispatched = false;
      return;
    }

    controller.printCurrentPage(
      settings: PrintJobSettings(
        jobName: '${_printJobName}_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    onPrintDispatched?.call();

    // Keep WebView alive long enough for the print adapter to snapshot it,
    // then tear it down.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _printFileUrl = '';
          _printDispatched = false;
        });
      }
    });
  }
}
