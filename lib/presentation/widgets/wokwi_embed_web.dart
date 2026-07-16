import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Browser-only Wokwi host. A unique view type prevents duplicate iframe
/// registrations when learners leave and reopen the lab.
class WokwiEmbed extends StatefulWidget {
  final String projectUrl;

  const WokwiEmbed({super.key, required this.projectUrl});

  @override
  State<WokwiEmbed> createState() => _WokwiEmbedState();
}

class _WokwiEmbedState extends State<WokwiEmbed> {
  static int _nextViewId = 0;
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'wokwi-simulator-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      return web.HTMLIFrameElement()
        ..src = widget.projectUrl
        ..title = 'Wokwi Arduino simulator'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'clipboard-read; clipboard-write; fullscreen';
    });
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
