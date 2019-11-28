import 'package:flutter/widgets.dart';

abstract class StepsAnimation {
  final AnimationController controller;

  StepsAnimation(this.controller);

  TransitionBuilder get builder;
}

abstract class OneStepAnimationData<T> {
  final Duration duration;

  final T animationData;

  OneStepAnimationData(this.duration, this.animationData);
}

typedef OneStepBuildAnimation<T> = Widget Function(
    BuildContext context, T data);

abstract class OneStepAnimation<T, AnimationData extends OneStepAnimationData<T>> {
  final AnimationData data;
  final OneStepBuildAnimation<T> oneStepBuildAnimation;

  OneStepAnimation(this.data, this.oneStepBuildAnimation);

  TransitionBuilder get builder => (BuildContext context, Widget child) {
        return oneStepBuildAnimation(context, data.animationData);
      };
}

abstract class OneStepAnimationBuilder {
  final Duration duration;

  OneStepAnimationBuilder(this.duration);

  OneStepAnimation buildStep(AnimationController controller,
      Duration startDuration, Duration totalDuration);
}
