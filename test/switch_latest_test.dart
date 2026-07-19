import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ngecode_juh/core/streaming/switch_latest.dart';

void main() {
  test('switches from a to b and ignores late events from a', () async {
    final outer = StreamController<Stream<String>>();
    final a = StreamController<String>.broadcast();
    final b = StreamController<String>.broadcast();
    final received = <String>[];
    final subscription = switchLatest(outer.stream).listen(received.add);

    outer.add(a.stream);
    await pumpEventQueue();

    a.add('initial from a');
    await pumpEventQueue();

    outer.add(b.stream);
    await pumpEventQueue();

    expect(a.hasListener, isFalse);
    expect(b.hasListener, isTrue);

    a.add('late from a');
    b.add('current from b');
    await pumpEventQueue();

    expect(received, ['initial from a', 'current from b']);

    await outer.close();
    await a.close();
    await b.close();
    await subscription.cancel();
  });
}
