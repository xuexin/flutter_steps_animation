import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'base.dart';

class _MultipleAnimationBuildInfo {
  final Animatable animatable;
  final Duration from;
  final Duration duration;
  final Object key;

  _MultipleAnimationBuildInfo(
      this.animatable, this.from, this.duration, this.key);
}

class MultipleAnimationBuilder extends OneStepAnimationBuilder {
  final List<_MultipleAnimationBuildInfo> buildInfoList = [];
  final OneStepBuildAnimation<Map<Object, Animation>> buildAnimation;

  MultipleAnimationBuilder({
    @required Duration duration,
    @required this.buildAnimation,
  })  : assert(duration != null && duration != Duration.zero),
        assert(buildAnimation != null),
        super(duration);

  MultipleAnimationBuilder addAnimatable({
    @required Animatable animatable,
    @required Duration from,
    @required Duration duration,
    @required key,
  }) {
    assert(from >= Duration.zero);
    assert(from + duration <= this.duration);
    assert(duration > Duration.zero);
    buildInfoList
        .add(_MultipleAnimationBuildInfo(animatable, from, duration, key));
    return this;
  }

  @override
  MultipleAnimation buildStep(AnimationController controller,
      Duration startDuration, Duration totalDuration) {
    final data = MultipleAnimationData(
        duration, startDuration, totalDuration, controller, buildInfoList);
    final multipleStepAnimation = MultipleAnimation(data, buildAnimation);
    return multipleStepAnimation;
  }
}

class MultipleAnimation extends OneStepAnimation<Map<Object, Animation>, MultipleAnimationData> {
  MultipleAnimation(MultipleAnimationData data,
      OneStepBuildAnimation<Map<Object, Animation>> oneStepBuildAnimation)
      : super(data, oneStepBuildAnimation);
}

class MultipleAnimationData
    extends OneStepAnimationData<Map<Object, Animation>> {
  MultipleAnimationData(
      Duration duration,
      Duration startDuration,
      Duration totalDuration,
      AnimationController controller,
      List<_MultipleAnimationBuildInfo> list)
      : super(
            duration,
            _createAnimationData(
                startDuration, totalDuration, controller, list));

  static Map<Object, Animation> _createAnimationData(
      Duration startDuration,
      Duration totalDuration,
      AnimationController controller,
      List<_MultipleAnimationBuildInfo> list) {
    final Map<Object, Animatable> animatableMap = {};
    final startInMilliseconds = startDuration.inMilliseconds;
    final totalInMilliseconds = totalDuration.inMilliseconds;
    list.forEach((_MultipleAnimationBuildInfo multipleInfo) {
      final double begin =
          (startInMilliseconds + multipleInfo.from.inMilliseconds).toDouble() /
              totalInMilliseconds;
      final double end = begin +
          multipleInfo.duration.inMilliseconds.toDouble() / totalInMilliseconds;
      CurveTween interval = CurveTween(curve: Interval(begin, end));

      final animatable = multipleInfo.animatable.chain(interval);
      final key = multipleInfo.key;
      if (animatableMap[key] == null) {
        animatableMap[key] = animatable;
      } else {
        final src = animatableMap[key];
        animatableMap[key] = _DstOverAnimatable(
            begin: begin, end: end, dst: animatable, src: src);
      }
    });
    final Map<Object, Animation> map = {};
    animatableMap.forEach((key, animatable) {
      map[key] = animatable.animate(controller);
    });
    return map;
  }
}

// Just like BlendMode.dstOver, dst over src
class _DstOverAnimatable extends Animatable {
  final double begin;
  final double end;
  final Animatable dst;
  final Animatable src;

  _DstOverAnimatable({
    @required this.begin,
    @required this.end,
    @required this.dst,
    this.src,
  });

  @override
  transform(double t) {
    if (src != null && !(t >= begin && t <= end)) {
      return src.transform(t);
    }
    return dst.transform(t);
  }
}
