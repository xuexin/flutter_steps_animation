import 'package:flutter/widgets.dart';

import 'base.dart';

class SingleAnimation<T extends Animation>
    extends OneStepAnimation<T, SingleAnimationData<T>> {
  SingleAnimation(SingleAnimationData<T> data, oneStepBuildAnimation)
      : super(data, oneStepBuildAnimation);
}

class SingleAnimationData<T extends Animation> extends OneStepAnimationData<T> {
  SingleAnimationData(
      Duration duration,
      Duration startDuration,
      Duration totalDuration,
      AnimationController controller,
      SingleAnimationBuildInfo info)
      : super(duration,
            _createAnimation(startDuration, totalDuration, controller, info));

  static Animation _createAnimation(
      Duration startDuration,
      Duration totalDuration,
      AnimationController controller,
      SingleAnimationBuildInfo info) {
    final startInMilliseconds = startDuration.inMilliseconds;
    final totalInMilliseconds = totalDuration.inMilliseconds;
    final double begin =
        (startInMilliseconds + info.from.inMilliseconds).toDouble() /
            totalInMilliseconds;
    final double end =
        begin + info.duration.inMilliseconds.toDouble() / totalInMilliseconds;
    CurveTween interval = CurveTween(curve: Interval(begin, end));
    final animatable = info.animatable.chain(interval);
    final animation = animatable.animate(controller);
    return animation;
  }
}

class SingleAnimationBuildInfo {
  final Animatable animatable;
  final Duration from;
  final Duration duration;

  SingleAnimationBuildInfo({
    @required this.animatable,
    @required this.from,
    @required this.duration,
  });
}

class SingleAnimationBuilder<T extends Animation>
    extends OneStepAnimationBuilder {
  final SingleAnimationBuildInfo buildInfo;
  final OneStepBuildAnimation<T> buildAnimation;

  SingleAnimationBuilder({
    @required Duration duration,
    @required this.buildAnimation,
    @required this.buildInfo,
  }) : super(duration);

  @override
  OneStepAnimation<T, SingleAnimationData<T>> buildStep(
      AnimationController controller,
      Duration startDuration,
      Duration totalDuration) {
    final data = SingleAnimationData<T>(
        duration, startDuration, totalDuration, controller, buildInfo);
    return SingleAnimation<T>(data, buildAnimation);
  }
}
