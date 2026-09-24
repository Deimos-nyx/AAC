// Basic smoke test: verifies the app builds and renders without throwing.
//
// The original Flutter counter-app template test was left in place after
// this project's real root widget (VoicePathApp) replaced MyApp, so it no
// longer matched anything in the app. Replace/expand this as real screens
// and flows get test coverage.

import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/app.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const VoicePathApp());
    await tester.pumpAndSettle();

    // No specific widget assertions yet — this just guards against the
    // widget tree throwing during build.
  });
}
