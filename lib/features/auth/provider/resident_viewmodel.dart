import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/provider/resident_service_provider.dart';
import '../../../core/services/resident_service.dart';

class FamilyListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ResidentService residentService;

  FamilyListNotifier(this.residentService) : super(const AsyncValue.loading());

  Future<void> fetchFamilies({String? name}) async {
    state = const AsyncValue.loading();
    try {
      final families = await residentService.getFamilyList(name: name);
      state = AsyncValue.data(families);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchFamilies(String query) async {
    if (query.isEmpty) {
      await fetchFamilies();
    } else {
      await fetchFamilies(name: query);
    }
  }
}

final familyListProvider = StateNotifierProvider<FamilyListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return FamilyListNotifier(residentService);
});

class OccupationListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ResidentService residentService;

  OccupationListNotifier(this.residentService) : super(const AsyncValue.loading());

  Future<void> fetchOccupations({String? name}) async {
    state = const AsyncValue.loading();
    try {
      final occupations = await residentService.getOccupationList(name: name);
      state = AsyncValue.data(occupations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchOccupations(String query) async {
    if (query.isEmpty) {
      await fetchOccupations();
    } else {
      await fetchOccupations(name: query);
    }
  }
}

final occupationListProvider = StateNotifierProvider<OccupationListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return OccupationListNotifier(residentService);
});


class ResidentSubmissionNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ResidentService residentService;

  ResidentSubmissionNotifier(this.residentService) : super(const AsyncValue.data({}));

  Future<void> submitResident({
    required String name,
    required String nik,
    required String placeOfBirth,
    required String dateOfBirth,
    required String gender,
    required String familyRole,
    required String familyId,
    required String occupationId,
    required File ktpFile,
    required File kkFile,
    required File birthCertificateFile,
    String? phone,
    String? religion,
    String? domicileStatus,
    String? status,
    String? bloodType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await residentService.createResidentSubmission(
        name: name,
        nik: nik,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
        gender: gender,
        familyRole: familyRole,
        familyId: familyId,
        occupationId: occupationId,
        ktpFile: ktpFile,
        kkFile: kkFile,
        birthCertificateFile: birthCertificateFile,
        phone: phone,
        religion: religion,
        domicileStatus: domicileStatus,
        status: status,
        bloodType: bloodType,
      );
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final residentSubmissionProvider = StateNotifierProvider<ResidentSubmissionNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return ResidentSubmissionNotifier(residentService);
});
