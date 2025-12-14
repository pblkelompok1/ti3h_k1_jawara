import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/auth_service_provider.dart';
import '../../../core/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final auth = ref.watch(authServiceProvider);
  return ProfileService(auth);
});

class ProfileData {
  final Map<String, dynamic> resident;
  final List<Map<String, dynamic>> occupations;

  ProfileData({
    required this.resident,
    required this.occupations,
  });

  ProfileData copyWith({
    Map<String, dynamic>? resident,
    List<Map<String, dynamic>>? occupations,
  }) {
    return ProfileData(
      resident: resident ?? this.resident,
      occupations: occupations ?? this.occupations,
    );
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileData>(ProfileController.new);

class ProfileController extends AsyncNotifier<ProfileData> {
  ProfileService get _svc => ref.read(profileServiceProvider);

  @override
  Future<ProfileData> build() async {
    final resident = await _svc.getMyResident();
    final occupations = await _svc.getOccupationList();
    return ProfileData(resident: resident, occupations: occupations);
  }

  Future<void> refreshAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final resident = await _svc.getMyResident();
      final occupations = await _svc.getOccupationList();
      return ProfileData(resident: resident, occupations: occupations);
    });
  }

  Future<void> updateEditableFields({
    required String? religion,
    required String? phone,
    required String? bloodType,
    required int? occupationId,
  }) async {
    final prev = state.value;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _svc.updateMyResident(
        religion: religion,
        phone: phone,
        bloodType: bloodType,
        occupationId: occupationId,
      );

      final resident = await _svc.getMyResident();
      final occupations = prev?.occupations ?? await _svc.getOccupationList();

      return ProfileData(resident: resident, occupations: occupations);
    });
  }

  Future<void> uploadPhoto(File file) async {
    final prev = state.value;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _svc.uploadProfileImage(file);

      final resident = await _svc.getMyResident();
      final occupations = prev?.occupations ?? await _svc.getOccupationList();

      return ProfileData(resident: resident, occupations: occupations);
    });
  }
}
