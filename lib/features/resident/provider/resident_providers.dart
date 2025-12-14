import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/provider/resident_service_provider.dart';
import '../../../core/services/resident_service.dart';

// ==================== RESIDENT LIST PROVIDER ====================
class ResidentListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ResidentService residentService;

  ResidentListNotifier(this.residentService) : super(const AsyncValue.loading());

  Future<void> fetchResidents({String? search, String? familyId}) async {
    state = const AsyncValue.loading();
    try {
      final result = await residentService.getResidentList(
        name: search,
        familyId: familyId,
        limit: 100,
      );
      
      final residents = List<Map<String, dynamic>>.from(result['data'] ?? []);
      state = AsyncValue.data(residents);
    } catch (e) {
      // Fallback to dummy data if API fails
      await Future.delayed(const Duration(milliseconds: 300));
      
      final dummyResidents = [
        {
          'id': '1',
          'name': 'Budi Santoso',
          'nik': '3201012345670001',
          'family_name': 'Keluarga Budi',
          'family_id': 'KL001',
          'occupation': 'Guru SD',
          'status': 'approved',
          'phone': '081234567890',
          'gender': 'Laki-laki',
          'date_of_birth': '1985-05-15',
          'place_of_birth': 'Jakarta',
          'role': 'Kepala Keluarga',
        },
        {
          'id': '2',
          'name': 'Siti Rahayu',
          'nik': '3201012345670002',
          'family_name': 'Keluarga Budi',
          'family_id': 'KL001',
          'occupation': 'Ibu Rumah Tangga',
          'status': 'approved',
          'phone': '081234567891',
          'gender': 'Perempuan',
          'date_of_birth': '1987-08-20',
          'place_of_birth': 'Bandung',
          'role': 'Istri',
        },
        {
          'id': '3',
          'name': 'Ahmad Fauzi',
          'nik': '3201012345670003',
          'family_name': 'Keluarga Ahmad',
          'family_id': 'KL002',
          'occupation': 'Wiraswasta',
          'status': 'approved',
          'phone': '081234567892',
          'gender': 'Laki-laki',
          'date_of_birth': '1980-03-10',
          'place_of_birth': 'Surabaya',
          'role': 'Kepala Keluarga',
        },
        {
          'id': '4',
          'name': 'Rina Wati',
          'nik': '3201012345670004',
          'family_name': 'Keluarga Ahmad',
          'family_id': 'KL002',
          'occupation': 'Pegawai Swasta',
          'status': 'approved',
          'phone': '081234567893',
          'gender': 'Perempuan',
          'date_of_birth': '1982-11-25',
          'place_of_birth': 'Yogyakarta',
          'role': 'Istri',
        },
        {
          'id': '5',
          'name': 'Doni Prasetyo',
          'nik': '3201012345670005',
          'family_name': 'Keluarga Doni',
          'family_id': 'KL003',
          'occupation': 'Dokter',
          'status': 'pending',
          'phone': '081234567894',
          'gender': 'Laki-laki',
          'date_of_birth': '1990-07-12',
          'place_of_birth': 'Semarang',
          'role': 'Kepala Keluarga',
        },
        {
          'id': '6',
          'name': 'Maya Sari',
          'nik': '3201012345670006',
          'family_name': 'Keluarga Doni',
          'family_id': 'KL003',
          'occupation': 'Perawat',
          'status': 'pending',
          'phone': '081234567895',
          'gender': 'Perempuan',
          'date_of_birth': '1992-09-05',
          'place_of_birth': 'Malang',
          'role': 'Istri',
        },
        {
          'id': '7',
          'name': 'Eko Wijaya',
          'nik': '3201012345670007',
          'family_name': 'Keluarga Eko',
          'family_id': 'KL004',
          'occupation': 'PNS',
          'status': 'approved',
          'phone': '081234567896',
          'gender': 'Laki-laki',
          'date_of_birth': '1978-12-30',
          'place_of_birth': 'Solo',
          'role': 'Kepala Keluarga',
        },
        {
          'id': '8',
          'name': 'Dewi Lestari',
          'nik': '3201012345670008',
          'family_name': 'Keluarga Eko',
          'family_id': 'KL004',
          'occupation': 'Guru SMP',
          'status': 'approved',
          'phone': '081234567897',
          'gender': 'Perempuan',
          'date_of_birth': '1980-04-18',
          'place_of_birth': 'Medan',
          'role': 'Istri',
        },
        {
          'id': '9',
          'name': 'Rudi Hartono',
          'nik': '3201012345670009',
          'family_name': 'Keluarga Rudi',
          'family_id': 'KL005',
          'occupation': 'Polisi',
          'status': 'rejected',
          'phone': '081234567898',
          'gender': 'Laki-laki',
          'date_of_birth': '1988-06-22',
          'place_of_birth': 'Palembang',
          'role': 'Kepala Keluarga',
        },
        {
          'id': '10',
          'name': 'Ani Yulianti',
          'nik': '3201012345670010',
          'family_name': 'Keluarga Budi',
          'family_id': 'KL001',
          'occupation': 'Pelajar SMA',
          'status': 'approved',
          'phone': '-',
          'gender': 'Perempuan',
          'date_of_birth': '2006-02-14',
          'place_of_birth': 'Jakarta',
          'role': 'Anak',
        },
        {
          'id': '11',
          'name': 'Joko Widodo',
          'nik': '3201012345670011',
          'family_name': 'Keluarga Ahmad',
          'family_id': 'KL002',
          'occupation': 'Pelajar SD',
          'status': 'approved',
          'phone': '-',
          'gender': 'Laki-laki',
          'date_of_birth': '2012-09-08',
          'place_of_birth': 'Surabaya',
          'role': 'Anak',
        },
        {
          'id': '12',
          'name': 'Linda Wijaya',
          'nik': '3201012345670012',
          'family_name': 'Keluarga Eko',
          'family_id': 'KL004',
          'occupation': 'Mahasiswa',
          'status': 'approved',
          'phone': '081234567899',
          'gender': 'Perempuan',
          'date_of_birth': '2003-11-11',
          'place_of_birth': 'Solo',
          'role': 'Anak',
        },
      ];
      
      // Filter by search if provided
      if (search != null && search.isNotEmpty) {
        final filtered = dummyResidents.where((r) {
          final name = (r['name'] ?? '').toString().toLowerCase();
          final family = (r['family_name'] ?? '').toString().toLowerCase();
          final query = search.toLowerCase();
          return name.contains(query) || family.contains(query);
        }).toList();
        state = AsyncValue.data(filtered);
      } else {
        state = AsyncValue.data(dummyResidents);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchResidents(String query) async {
    if (query.isEmpty) {
      await fetchResidents();
    } else {
      await fetchResidents(search: query);
    }
  }
}

final residentListProvider = StateNotifierProvider<ResidentListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return ResidentListNotifier(residentService);
});

// ==================== FAMILY LIST PROVIDER ====================
class FamilyListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final ResidentService residentService;

  FamilyListNotifier(this.residentService) : super(const AsyncValue.loading());

  Future<void> fetchFamilies() async {
    state = const AsyncValue.loading();
    try {
      final result = await residentService.getFamilyList();
      final families = List<Map<String, dynamic>>.from(result);
      state = AsyncValue.data(families);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final familyListProvider = StateNotifierProvider<FamilyListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return FamilyListNotifier(residentService);
});

// ==================== RESIDENT DETAIL PROVIDER ====================
class ResidentDetailNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ResidentService residentService;

  ResidentDetailNotifier(this.residentService) : super(const AsyncValue.data({}));

  Future<void> fetchResidentDetail(String residentId) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Replace with actual API endpoint when available
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Dummy resident details
      final allResidents = {
        '1': {
          'id': '1',
          'name': 'Budi Santoso',
          'nik': '3201012345670001',
          'family_name': 'Keluarga Budi',
          'occupation': 'Guru SD',
          'status': 'approved',
          'phone': '081234567890',
          'gender': 'Laki-laki',
          'date_of_birth': '15 Mei 1985',
          'place_of_birth': 'Jakarta',
          'role': 'Kepala Keluarga',
          'address': 'Jl. Merdeka No. 123, RT 01/RW 02',
        },
        '2': {
          'id': '2',
          'name': 'Siti Rahayu',
          'nik': '3201012345670002',
          'family_name': 'Keluarga Budi',
          'occupation': 'Ibu Rumah Tangga',
          'status': 'approved',
          'phone': '081234567891',
          'gender': 'Perempuan',
          'date_of_birth': '20 Agustus 1987',
          'place_of_birth': 'Bandung',
          'role': 'Istri',
          'address': 'Jl. Merdeka No. 123, RT 01/RW 02',
        },
        '3': {
          'id': '3',
          'name': 'Ahmad Fauzi',
          'nik': '3201012345670003',
          'family_name': 'Keluarga Ahmad',
          'occupation': 'Wiraswasta',
          'status': 'approved',
          'phone': '081234567892',
          'gender': 'Laki-laki',
          'date_of_birth': '10 Maret 1980',
          'place_of_birth': 'Surabaya',
          'role': 'Kepala Keluarga',
          'address': 'Jl. Sudirman No. 45, RT 02/RW 03',
        },
      };
      
      final detail = allResidents[residentId] ?? {
        'id': residentId,
        'name': 'Unknown',
        'nik': '-',
        'family_name': '-',
        'occupation': '-',
        'status': 'pending',
        'phone': '-',
        'gender': '-',
        'date_of_birth': '-',
        'place_of_birth': '-',
      };
      
      state = AsyncValue.data(detail);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearDetail() {
    state = const AsyncValue.data({});
  }
}

final residentDetailProvider = StateNotifierProvider<ResidentDetailNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return ResidentDetailNotifier(residentService);
});

// ==================== FAMILY DETAIL PROVIDER ====================
class FamilyDetailNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ResidentService residentService;

  FamilyDetailNotifier(this.residentService) : super(const AsyncValue.data({}));

  Future<void> fetchFamilyDetail(String familyId) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Replace with actual API endpoint when available
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Dummy family details based on family ID
      final familyDetails = {
        'KL001': {
          'family_id': 'KL001',
          'family_name': 'Keluarga Budi',
          'head_name': 'Budi Santoso',
          'address': 'Jl. Merdeka No. 123, RT 01/RW 02',
          'member_count': 3,
          'members': [
            {
              'id': '1',
              'name': 'Budi Santoso',
              'role': 'Kepala Keluarga',
              'status': 'approved',
              'gender': 'Laki-laki',
              'occupation': 'Guru SD',
            },
            {
              'id': '2',
              'name': 'Siti Rahayu',
              'role': 'Istri',
              'status': 'approved',
              'gender': 'Perempuan',
              'occupation': 'Ibu Rumah Tangga',
            },
            {
              'id': '10',
              'name': 'Ani Yulianti',
              'role': 'Anak',
              'status': 'approved',
              'gender': 'Perempuan',
              'occupation': 'Pelajar SMA',
            },
          ],
        },
        'KL002': {
          'family_id': 'KL002',
          'family_name': 'Keluarga Ahmad',
          'head_name': 'Ahmad Fauzi',
          'address': 'Jl. Sudirman No. 45, RT 02/RW 03',
          'member_count': 3,
          'members': [
            {
              'id': '3',
              'name': 'Ahmad Fauzi',
              'role': 'Kepala Keluarga',
              'status': 'approved',
              'gender': 'Laki-laki',
              'occupation': 'Wiraswasta',
            },
            {
              'id': '4',
              'name': 'Rina Wati',
              'role': 'Istri',
              'status': 'approved',
              'gender': 'Perempuan',
              'occupation': 'Pegawai Swasta',
            },
            {
              'id': '11',
              'name': 'Joko Widodo',
              'role': 'Anak',
              'status': 'approved',
              'gender': 'Laki-laki',
              'occupation': 'Pelajar SD',
            },
          ],
        },
        'KL003': {
          'family_id': 'KL003',
          'family_name': 'Keluarga Doni',
          'head_name': 'Doni Prasetyo',
          'address': 'Jl. Gatot Subroto No. 78, RT 03/RW 04',
          'member_count': 2,
          'members': [
            {
              'id': '5',
              'name': 'Doni Prasetyo',
              'role': 'Kepala Keluarga',
              'status': 'pending',
              'gender': 'Laki-laki',
              'occupation': 'Dokter',
            },
            {
              'id': '6',
              'name': 'Maya Sari',
              'role': 'Istri',
              'status': 'pending',
              'gender': 'Perempuan',
              'occupation': 'Perawat',
            },
          ],
        },
        'KL004': {
          'family_id': 'KL004',
          'family_name': 'Keluarga Eko',
          'head_name': 'Eko Wijaya',
          'address': 'Jl. Ahmad Yani No. 90, RT 04/RW 05',
          'member_count': 3,
          'members': [
            {
              'id': '7',
              'name': 'Eko Wijaya',
              'role': 'Kepala Keluarga',
              'status': 'approved',
              'gender': 'Laki-laki',
              'occupation': 'PNS',
            },
            {
              'id': '8',
              'name': 'Dewi Lestari',
              'role': 'Istri',
              'status': 'approved',
              'gender': 'Perempuan',
              'occupation': 'Guru SMP',
            },
            {
              'id': '12',
              'name': 'Linda Wijaya',
              'role': 'Anak',
              'status': 'approved',
              'gender': 'Perempuan',
              'occupation': 'Mahasiswa',
            },
          ],
        },
        'KL005': {
          'family_id': 'KL005',
          'family_name': 'Keluarga Rudi',
          'head_name': 'Rudi Hartono',
          'address': 'Jl. Diponegoro No. 12, RT 05/RW 06',
          'member_count': 1,
          'members': [
            {
              'id': '9',
              'name': 'Rudi Hartono',
              'role': 'Kepala Keluarga',
              'status': 'rejected',
              'gender': 'Laki-laki',
              'occupation': 'Polisi',
            },
          ],
        },
      };
      
      final detail = familyDetails[familyId] ?? {
        'family_id': familyId,
        'family_name': 'Keluarga Unknown',
        'head_name': '-',
        'address': '-',
        'member_count': 0,
        'members': [],
      };
      
      state = AsyncValue.data(detail);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearDetail() {
    state = const AsyncValue.data({});
  }
}

final familyDetailProvider = StateNotifierProvider<FamilyDetailNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return FamilyDetailNotifier(residentService);
});

// ==================== MY FAMILY PROVIDER ====================
class MyFamilyNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ResidentService residentService;

  MyFamilyNotifier(this.residentService) : super(const AsyncValue.loading());

  Future<void> fetchMyFamily() async {
    state = const AsyncValue.loading();
    try {
      // Get user's family ID first
      final familyId = await residentService.getUserFamilyId();
      
      if (familyId == null) {
        // User doesn't have a family yet
        state = const AsyncValue.data({});
        return;
      }

      // Get family members
      final members = await residentService.getMyFamilyResidents();
      
      if (members.isEmpty) {
        state = const AsyncValue.data({});
        return;
      }

      // Find head of family
      final headMember = members.firstWhere(
        (m) => (m['family_role'] ?? m['role'])?.toLowerCase() == 'kepala keluarga',
        orElse: () => members.first,
      );

      // Get family info from family list endpoint
      final familyList = await residentService.getFamilyList();
      final familyInfo = familyList.firstWhere(
        (f) => f['family_id'] == familyId,
        orElse: () => {
          'family_id': familyId,
          'family_name': 'Keluarga Saya',
          'head_of_family': headMember['name'],
        },
      );

      final myFamily = {
        'family_id': familyId,
        'family_name': familyInfo['family_name'] ?? 'Keluarga Saya',
        'is_head': true, // TODO: Check if current user is head
        'head_name': familyInfo['head_of_family'] ?? headMember['name'],
        'member_count': members.length,
        'members': members,
      };
      
      state = AsyncValue.data(myFamily);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateMember(String memberId, Map<String, dynamic> updatedData) async {
    try {
      // TODO: Replace with actual API endpoint when available
      await Future.delayed(const Duration(milliseconds: 500));
      
      state.whenData((family) {
        final members = List<Map<String, dynamic>>.from(family['members'] ?? []);
        final index = members.indexWhere((m) => m['id'] == memberId);
        if (index != -1) {
          members[index] = {...members[index], ...updatedData};
          state = AsyncValue.data({...family, 'members': members});
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final myFamilyProvider = StateNotifierProvider<MyFamilyNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final residentService = ref.read(residentServiceProvider);
  return MyFamilyNotifier(residentService);
});

// ==================== SEARCH QUERY PROVIDER ====================
final searchQueryProvider = StateProvider<String>((ref) => '');

// ==================== SELECTED TAB PROVIDER ====================
final selectedTabProvider = StateProvider<int>((ref) => 0);

// ==================== FILTER STATUS PROVIDER ====================
final filterStatusProvider = StateProvider<String>((ref) => '');

// ==================== DUMMY FAMILIES PROVIDER ====================
final dummyFamiliesProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'family_id': 'KL001',
      'family_name': 'Keluarga Budi',
      'head_name': 'Budi Santoso',
      'member_count': 3,
    },
    {
      'family_id': 'KL002',
      'family_name': 'Keluarga Ahmad',
      'head_name': 'Ahmad Fauzi',
      'member_count': 3,
    },
    {
      'family_id': 'KL003',
      'family_name': 'Keluarga Doni',
      'head_name': 'Doni Prasetyo',
      'member_count': 2,
    },
    {
      'family_id': 'KL004',
      'family_name': 'Keluarga Eko',
      'head_name': 'Eko Wijaya',
      'member_count': 3,
    },
    {
      'family_id': 'KL005',
      'family_name': 'Keluarga Rudi',
      'head_name': 'Rudi Hartono',
      'member_count': 1,
    },
  ];
});
