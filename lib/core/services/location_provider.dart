import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/services/location_service.dart';

final userLocationProvider = AsyncNotifierProvider<UserLocationNotifier, String>(() {
  return UserLocationNotifier();
});

class UserLocationNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return _fetch();
  }

  Future<String> _fetch() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final addressData = await LocationService.getAddressFromLatLng(position);
        return addressData?['city'] ?? 'Unknown Location';
      }
      return 'Location Disabled';
    } catch (e) {
      return 'Location Error';
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}
