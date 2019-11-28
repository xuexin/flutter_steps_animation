import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

import 'base.dart';

class NoneAnimation extends OneStepAnimation<dynamic, NoneAnimationData> {
  NoneAnimation(NoneAnimationData animationData,
      OneStepBuildAnimation<NoneAnimationData> oneStepBuildAnimation)
      : super(animationData, oneStepBuildAnimation);
}

class NoneAnimationData extends OneStepAnimationData {
  NoneAnimationData(Duration duration) : super(duration, null);
}

class NoneAnimationBuilder extends OneStepAnimationBuilder {
  WidgetBuilder builder;

  NoneAnimationBuilder({@required Duration duration, @required this.builder})
      : super(duration);

  @override
  OneStepAnimation buildStep(AnimationController controller,
      Duration startDuration, Duration totalDuration) {
    final animationData = NoneAnimationData(duration);
    return NoneAnimation(animationData, (context, dynamic _) {
      return builder(context);
    });
  }
}
