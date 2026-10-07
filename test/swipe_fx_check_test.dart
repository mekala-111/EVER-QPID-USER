import 'package:everqpidapp/Features/home/view/swipe_feedback_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('swipe FX progress / scale math', () {
    expect(SwipeEffectOverlay.progressFromDx(0, 400), 0);
    expect(SwipeEffectOverlay.progressFromDx(120, 400), 1.0);
    expect(SwipeEffectOverlay.fxFromDx(20), SwipeFx.love);
    expect(SwipeEffectOverlay.fxFromDx(-20), SwipeFx.pass);
    expect(SwipeEffectOverlay.fxFromDx(0), SwipeFx.none);
    expect(SwipeEffectOverlay.swipeProfileOpacity(0), 1.0);
    expect(SwipeEffectOverlay.swipeProfileOpacity(1), 0.75);
    expect(SwipeEffectOverlay.celebrateScale(0), closeTo(0.65, 1e-6));
    expect(SwipeEffectOverlay.celebrateScale(0.35), closeTo(1.0, 1e-6));
    expect(SwipeEffectOverlay.celebrateScale(0.55), greaterThan(1.1));
    expect(SwipeEffectOverlay.celebrateScale(0.75), closeTo(1.0, 1e-5));
    expect(SwipeEffectOverlay.celebrateFade(0.5), 1.0);
    expect(SwipeEffectOverlay.celebrateFade(1.0), 0.0);
    final mobile = SwipeEffectOverlay.heartExtent(const Size(390, 844));
    expect(mobile, inInclusiveRange(160, 240));
    final desktop = SwipeEffectOverlay.heartExtent(const Size(1280, 800));
    expect(desktop, inInclusiveRange(260, 380));
  });
}
