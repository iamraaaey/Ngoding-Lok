import 'dart:async';

/// Emits values from only the most recently received inner stream.
///
/// When [streams] emits a replacement stream, the previous subscription is
/// cancelled and any late values from it are ignored. The returned stream
/// closes after the outer stream and its current inner stream have both
/// completed.
Stream<T> switchLatest<T>(Stream<Stream<T>> streams) {
  late final StreamController<T> controller;
  StreamSubscription<Stream<T>>? outerSubscription;
  StreamSubscription<T>? innerSubscription;
  var outerDone = false;
  var cancelled = false;
  var paused = false;
  var switchVersion = 0;
  var pendingSwitches = 0;
  Future<void> pendingTransition = Future<void>.value();

  void closeWhenComplete() {
    if (!cancelled &&
        outerDone &&
        pendingSwitches == 0 &&
        innerSubscription == null) {
      unawaited(controller.close());
    }
  }

  Future<void> cancelInner(StreamSubscription<T>? subscription) async {
    if (subscription == null) return;
    try {
      await subscription.cancel();
    } catch (error, stackTrace) {
      if (!cancelled) controller.addError(error, stackTrace);
    }
  }

  void switchTo(Stream<T> nextStream) {
    final version = ++switchVersion;
    final previousSubscription = innerSubscription;
    innerSubscription = null;
    pendingSwitches += 1;

    // Start cancellation right away. The queued transition only starts the
    // next subscription once any previous cancellation has finished.
    final cancellation = cancelInner(previousSubscription);
    pendingTransition = pendingTransition
        .then((_) async {
          await cancellation;
          if (cancelled || version != switchVersion) return;

          var completedBeforeAttach = false;
          var attached = false;
          final subscription = nextStream.listen(
            (event) {
              if (!cancelled && version == switchVersion) {
                controller.add(event);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (!cancelled && version == switchVersion) {
                controller.addError(error, stackTrace);
              }
            },
            onDone: () {
              if (cancelled || version != switchVersion) return;
              completedBeforeAttach = true;
              if (attached) {
                innerSubscription = null;
                closeWhenComplete();
              }
            },
          );

          attached = true;
          if (cancelled || version != switchVersion) {
            await cancelInner(subscription);
            return;
          }
          if (completedBeforeAttach) {
            closeWhenComplete();
            return;
          }

          innerSubscription = subscription;
          if (paused) subscription.pause();
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (!cancelled) controller.addError(error, stackTrace);
        })
        .whenComplete(() {
          pendingSwitches -= 1;
          closeWhenComplete();
        });
  }

  controller = StreamController<T>(
    onListen: () {
      outerSubscription = streams.listen(
        switchTo,
        onError: controller.addError,
        onDone: () {
          outerDone = true;
          closeWhenComplete();
        },
      );
    },
    onPause: () {
      paused = true;
      outerSubscription?.pause();
      innerSubscription?.pause();
    },
    onResume: () {
      paused = false;
      outerSubscription?.resume();
      innerSubscription?.resume();
    },
    onCancel: () async {
      cancelled = true;
      switchVersion += 1;
      await outerSubscription?.cancel();
      await cancelInner(innerSubscription);
      await pendingTransition;
    },
  );

  return controller.stream;
}
