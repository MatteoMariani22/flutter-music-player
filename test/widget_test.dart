import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music_player/main.dart';

void main() {
  testWidgets('dashboard renders mock music and player controls work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SoundwaveApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNWidgets(2));
    expect(find.text('Afterglow'), findsOneWidget);
    expect(find.text('Midnight City'), findsAtLeastNWidgets(2));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Next track').first);
    await tester.pumpAndSettle();
    expect(find.text('The Less I Know The Better'), findsAtLeastNWidgets(2));

    await tester.tap(find.byTooltip('Pause').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard adapts to a narrow mobile layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SoundwaveApp());
    await tester.pumpAndSettle();

    expect(find.text('soundwave'), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
