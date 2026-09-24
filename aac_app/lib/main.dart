import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Deliberately minimal: no analytics/crash SDK initialization here by
  // default (spec section 15 — collect the minimum possible data). Add one
  // in AppLogger (core/services/logger_service.dart) if a project later
  // decides it needs crash reporting; that's the single seam for it.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoicePathApp());
}
