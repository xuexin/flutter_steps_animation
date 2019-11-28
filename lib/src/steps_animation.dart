import 'package:flutter/widgets.dart';

import 'base.dart';

class _StepsAnimationImpl extends StepsAnimation {
  final List<OneStepAnimation> stepAnimations;
  final List<double> stepDurationCostingList;

  _StepsAnimationImpl._internal(AnimationController controller,
      this.stepAnimations, this.stepDurationCostingList)
      : super(controller);

  @override
  get builder => (BuildContext context, Widget child) {
        return getCurrentStep().builder(context, child);
      };

  //todo This method assumes that controller's lowerBound and upperBound is 0 and 1
  OneStepAnimation getCurrentStep() {
    final value = controller.value;
    for (int i = 0; i < stepDurationCostingList.length; i++) {
      if (stepDurationCostingList[i] > value) {
        return stepAnimations[i - 1];
      }
    }
    return stepAnimations.last;
  }
}

class StepsAnimationBuilder {
  final List<OneStepAnimationBuilder> stepBuilders = [];

  StepsAnimationBuilder addStepBuilder(OneStepAnimationBuilder stepBuilder) {
    stepBuilders.add(stepBuilder);
    return this;
  }

  _StepsAnimationImpl animation(TickerProvider vsync) {
    final duration = _calculateTotalDuration();
    //todo lowerBound and upperBound must be 0 and 1.
    final controller = AnimationController(
        vsync: vsync, duration: duration, lowerBound: 0, upperBound: 1);
    final stepAnimations = <OneStepAnimation>[];
    final stepDurationCostingList = <double>[];
    Duration stepStartDuration = Duration.zero;
    stepDurationCostingList.add(0);
    stepBuilders.forEach((stepBuilder) {
      final step =
          stepBuilder.buildStep(controller, stepStartDuration, duration);
      stepStartDuration += stepBuilder.duration;
      stepDurationCostingList.add(stepStartDuration.inMilliseconds.toDouble() /
          duration.inMilliseconds.toDouble());
      stepAnimations.add(step);
    });
    return _StepsAnimationImpl._internal(
        controller, stepAnimations, stepDurationCostingList);
  }

  Duration _calculateTotalDuration() {
    Duration duration = Duration.zero;
    stepBuilders.forEach((step) {
      duration += step.duration;
    });
    return duration;
  }
}
