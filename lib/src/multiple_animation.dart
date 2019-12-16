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
    assert(animatable != null);
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

class MultipleAnimation
    extends OneStepAnimation<Map<Object, Animation>, MultipleAnimationData> {
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
    final Map<Object, _StartTimeSortedAnimatable> animatableMap = {};
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
        animatableMap[key] = _StartTimeSortedAnimatable()
          ..addAnimatable(animatable, begin, end, key);
      } else {
        animatableMap[key].addAnimatable(animatable, begin, end, key);
      }
    });
    final Map<Object, Animation> map = {};
    animatableMap.forEach((key, animatable) {
      map[key] = animatable.animate(controller);
    });
    return map;
  }
}

class _AnimatableAndStartTime {
  final Animatable animatable;
  final double begin;
  final double end;

  _AnimatableAndStartTime(this.animatable, this.begin, this.end);
}

class _StartTimeSortedAnimatable extends Animatable {
  final animatableList = <_AnimatableAndStartTime>[];

  void addAnimatable(Animatable animatable, double begin, double end, Object key) {
    animatableList.add(_AnimatableAndStartTime(animatable, begin, end));
    animatableList.sort((a, b) {
      return a.begin.compareTo(b.begin);
    });
    assert(() {
      _AnimatableAndStartTime preAnimatable;
      for (final animatable in animatableList) {
        if (preAnimatable == null) {
          preAnimatable = animatable;
          continue;
        }
        if (preAnimatable.end > animatable.begin) {
          throw 'Animatable of \'$key\' conflicts';
        }
        preAnimatable = animatable;
      }
      return true;
    }());
  }

  Animatable getAppropriateAnimatable(double t) {
    assert(animatableList.length != 0);
    for (int i = 0; i < animatableList.length; ++i) {
      switch (t.compareTo(animatableList[i].begin)) {
        case -1:
          int index = i - 1 >= 0 ? i - 1 : 0;
          return animatableList[index].animatable;
          break;
        case 0:
          return animatableList[i].animatable;
          break;
        case 1:
          continue;
          break;
      }
    }
    return animatableList.last.animatable;
  }

  @override
  transform(double t) {
    final currentAnimatable = getAppropriateAnimatable(t);
    return currentAnimatable.transform(t);
  }
}
