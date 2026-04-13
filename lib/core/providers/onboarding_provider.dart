import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingTourProvider = NotifierProvider<OnboardingTourNotifier, bool>(() {
  return OnboardingTourNotifier();
});

class OnboardingTourNotifier extends Notifier<bool> {
  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('has_completed_onboarding_tour') ?? false;
  }

  Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding_tour', true);
    state = true;
  }
}
