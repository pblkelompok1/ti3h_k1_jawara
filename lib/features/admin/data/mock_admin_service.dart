import 'package:ti3h_k1_jawara/features/admin/data/admin_models.dart';

/// Mock Admin Service untuk testing tanpa backend
/// Menggantikan API calls dengan data dummy
class MockAdminService {
  // Simulate API delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  final bool simulateDelay;
  MockAdminService({this.simulateDelay = true});

  // ============= MOCK DATA =============

  static final List<PendingRegistration> _mockPendingRegistrations = [
    PendingRegistration(
      id: '1',
      email: 'budi.santoso@email.com',
      name: 'Budi Santoso',
      nik: '3201012345678901',
      phone: '081234567890',
      address: 'Jl. Merdeka No. 123, RT 01/RW 05',
      familyRole: 'Kepala Keluarga',
      status: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      documents: {
        'ktp': 'https://example.com/ktp1.jpg',
        'kk': 'https://example.com/kk1.jpg',
      },
    ),
    PendingRegistration(
      id: '2',
      email: 'siti.aminah@email.com',
      name: 'Siti Aminah',
      nik: '3201012345678902',
      phone: '081234567891',
      address: 'Jl. Kenanga No. 45, RT 02/RW 03',
      familyRole: 'Istri',
      status: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PendingRegistration(
      id: '3',
      email: 'ahmad.hidayat@email.com',
      name: 'Ahmad Hidayat',
      nik: '3201012345678903',
      phone: '081234567892',
      address: 'Jl. Melati No. 78, RT 03/RW 02',
      familyRole: 'Kepala Keluarga',
      status: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static final List<FinanceReport> _mockFinanceReports = [
    FinanceReport(
      id: '1',
      category: 'Iuran Bulanan',
      amount: 50000,
      description: 'Iuran RT bulan Desember 2025 dari Budi Santoso',
      date: DateTime(2025, 12, 1),
      type: 'income',
      residentName: 'Budi Santoso',
    ),
    FinanceReport(
      id: '2',
      category: 'Iuran Bulanan',
      amount: 50000,
      description: 'Iuran RT bulan Desember 2025 dari Siti Aminah',
      date: DateTime(2025, 12, 1),
      type: 'income',
      residentName: 'Siti Aminah',
    ),
    FinanceReport(
      id: '3',
      category: 'Kebersihan',
      amount: 150000,
      description: 'Pembayaran tukang sampah',
      date: DateTime(2025, 12, 2),
      type: 'expense',
    ),
    FinanceReport(
      id: '4',
      category: 'Iuran Bulanan',
      amount: 50000,
      description: 'Iuran RT bulan Desember 2025 dari Ahmad Hidayat',
      date: DateTime(2025, 12, 3),
      type: 'income',
      residentName: 'Ahmad Hidayat',
    ),
    FinanceReport(
      id: '5',
      category: 'Keamanan',
      amount: 200000,
      description: 'Gaji satpam bulan Desember',
      date: DateTime(2025, 12, 3),
      type: 'expense',
    ),
  ];

  static final List<BannerModel> _mockBanners = [
    BannerModel(
      id: '1',
      title: 'Selamat Datang',
      subtitle: 'Aplikasi Digital RT Modern',
      iconName: 'home',
      type: 'dashboard',
      priority: 1,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    BannerModel(
      id: '2',
      title: 'Info Iuran',
      subtitle: 'Jangan lupa bayar iuran bulanan',
      iconName: 'payment',
      type: 'dashboard',
      priority: 2,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    BannerModel(
      id: '3',
      title: 'Promo Warung Bu Ijah',
      subtitle: 'Diskon 20% untuk semua produk',
      imageUrl: 'https://via.placeholder.com/400x200',
      type: 'marketplace',
      priority: 1,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static final List<ProblemReport> _mockProblemReports = [
    ProblemReport(
      id: '1',
      title: 'Lampu Jalan Mati',
      description: 'Lampu jalan di depan RT mati sudah 3 hari',
      category: 'Infrastruktur',
      status: 'new',
      reporterName: 'Budi Santoso',
      reporterId: '101',
      reporterPhone: '081234567890',
      location: 'Jl. Merdeka depan pos RT',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProblemReport(
      id: '2',
      title: 'Sampah Menumpuk',
      description: 'Sampah di TPS belum diangkut 2 hari',
      category: 'Kebersihan',
      status: 'in_progress',
      reporterName: 'Siti Aminah',
      reporterId: '102',
      reporterPhone: '081234567891',
      location: 'TPS RT 01',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      assignedTo: 'Admin 1',
      notes: 'Sudah dikonfirmasi ke dinas kebersihan',
    ),
    ProblemReport(
      id: '3',
      title: 'Jalan Berlubang',
      description: 'Ada lubang besar di jalan, berbahaya untuk motor',
      category: 'Infrastruktur',
      status: 'new',
      reporterName: 'Ahmad Hidayat',
      reporterId: '103',
      reporterPhone: '081234567892',
      location: 'Jl. Kenanga RT 02',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  static final List<LetterRequest> _mockLetterRequests = [
    LetterRequest(
      id: '1',
      letterType: 'Surat Keterangan Domisili',
      requesterName: 'Budi Santoso',
      requesterId: '101',
      requesterPhone: '081234567890',
      purpose: 'Untuk pembuatan KTP',
      status: 'pending',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LetterRequest(
      id: '2',
      letterType: 'Surat Pengantar SKCK',
      requesterName: 'Ahmad Hidayat',
      requesterId: '103',
      requesterPhone: '081234567892',
      purpose: 'Untuk melamar pekerjaan',
      status: 'pending',
      requestDate: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    LetterRequest(
      id: '3',
      letterType: 'Surat Keterangan Tidak Mampu',
      requesterName: 'Siti Aminah',
      requesterId: '102',
      requesterPhone: '081234567891',
      purpose: 'Untuk beasiswa anak',
      status: 'approved',
      requestDate: DateTime.now().subtract(const Duration(days: 5)),
      approvedDate: DateTime.now().subtract(const Duration(days: 4)),
      approvedBy: 'Admin 1',
      notes: 'Sudah disetujui, silakan ambil di kantor RT',
    ),
  ];

  static final List<Map<String, dynamic>> _mockResidents = [
    {
      'id': '101',
      'name': 'Budi Santoso',
      'nik': '3201012345678901',
      'phone': '081234567890',
      'address': 'Jl. Merdeka No. 123, RT 01/RW 05',
      'family_role': 'Kepala Keluarga',
      'family_id': 'F001',
      'family_name': 'Keluarga Budi',
      'status': 'approved',
      'occupation': 'Wiraswasta',
      'gender': 'Laki-laki',
      'date_of_birth': '1985-05-15',
    },
    {
      'id': '102',
      'name': 'Siti Aminah',
      'nik': '3201012345678902',
      'phone': '081234567891',
      'address': 'Jl. Merdeka No. 123, RT 01/RW 05',
      'family_role': 'Istri',
      'family_id': 'F001',
      'family_name': 'Keluarga Budi',
      'status': 'approved',
      'occupation': 'Ibu Rumah Tangga',
      'gender': 'Perempuan',
      'date_of_birth': '1987-08-20',
    },
    {
      'id': '103',
      'name': 'Ahmad Hidayat',
      'nik': '3201012345678903',
      'phone': '081234567892',
      'address': 'Jl. Kenanga No. 45, RT 02/RW 03',
      'family_role': 'Kepala Keluarga',
      'family_id': 'F002',
      'family_name': 'Keluarga Ahmad',
      'status': 'approved',
      'occupation': 'Pegawai Swasta',
      'gender': 'Laki-laki',
      'date_of_birth': '1990-03-10',
    },
    {
      'id': '104',
      'name': 'Dewi Lestari',
      'nik': '3201012345678904',
      'phone': '081234567893',
      'address': 'Jl. Melati No. 78, RT 03/RW 02',
      'family_role': 'Kepala Keluarga',
      'family_id': 'F003',
      'family_name': 'Keluarga Dewi',
      'status': 'approved',
      'occupation': 'Guru',
      'gender': 'Perempuan',
      'date_of_birth': '1988-11-25',
    },
  ];

  static AdminStatistics _mockStatistics = AdminStatistics(
    totalResidents: 45,
    pendingRegistrations: 3,
    activeUsers: 42,
    newReportsToday: 1,
    pendingLetters: 2,
    monthlyIncome: 2250000,
    monthlyExpense: 850000,
    totalFamilies: 15,
  );

  // ============= API METHODS =============

  // Registration Approval View
  Future<List<PendingRegistration>> getPendingRegistrations() async {
    if (simulateDelay) await _delay();
    return _mockPendingRegistrations.where((r) => r.status == 'pending').toList();
  }

  Future<bool> approveRegistration(String userId) async {
    if (simulateDelay) await _delay();
    final index = _mockPendingRegistrations.indexWhere((r) => r.id == userId);
    if (index != -1) {
      _mockPendingRegistrations[index] = PendingRegistration(
        id: _mockPendingRegistrations[index].id,
        email: _mockPendingRegistrations[index].email,
        name: _mockPendingRegistrations[index].name,
        nik: _mockPendingRegistrations[index].nik,
        phone: _mockPendingRegistrations[index].phone,
        address: _mockPendingRegistrations[index].address,
        familyRole: _mockPendingRegistrations[index].familyRole,
        status: 'approved',
        submittedAt: _mockPendingRegistrations[index].submittedAt,
        documents: _mockPendingRegistrations[index].documents,
      );
      _mockStatistics = AdminStatistics(
        totalResidents: _mockStatistics.totalResidents + 1,
        pendingRegistrations: _mockStatistics.pendingRegistrations - 1,
        activeUsers: _mockStatistics.activeUsers + 1,
        newReportsToday: _mockStatistics.newReportsToday,
        pendingLetters: _mockStatistics.pendingLetters,
        monthlyIncome: _mockStatistics.monthlyIncome,
        monthlyExpense: _mockStatistics.monthlyExpense,
        totalFamilies: _mockStatistics.totalFamilies,
      );
      return true;
    }
    return false;
  }

  Future<bool> rejectRegistration(String userId, String reason) async {
    if (simulateDelay) await _delay();
    final index = _mockPendingRegistrations.indexWhere((r) => r.id == userId);
    if (index != -1) {
      _mockPendingRegistrations[index] = PendingRegistration(
        id: _mockPendingRegistrations[index].id,
        email: _mockPendingRegistrations[index].email,
        name: _mockPendingRegistrations[index].name,
        nik: _mockPendingRegistrations[index].nik,
        phone: _mockPendingRegistrations[index].phone,
        address: _mockPendingRegistrations[index].address,
        familyRole: _mockPendingRegistrations[index].familyRole,
        status: 'rejected',
        submittedAt: _mockPendingRegistrations[index].submittedAt,
        documents: _mockPendingRegistrations[index].documents,
      );
      _mockStatistics = AdminStatistics(
        totalResidents: _mockStatistics.totalResidents,
        pendingRegistrations: _mockStatistics.pendingRegistrations - 1,
        activeUsers: _mockStatistics.activeUsers,
        newReportsToday: _mockStatistics.newReportsToday,
        pendingLetters: _mockStatistics.pendingLetters,
        monthlyIncome: _mockStatistics.monthlyIncome,
        monthlyExpense: _mockStatistics.monthlyExpense,
        totalFamilies: _mockStatistics.totalFamilies,
      );
      return true;
    }
    return false;
  }

  // Dashboard View
  Future<AdminStatistics> getStatistics() async {
    if (simulateDelay) await _delay();
    return _mockStatistics;
  }

  // Finance Summary for Dashboard
  Future<FinanceSummary> getFinanceSummary() async {
    if (simulateDelay) await _delay();
    double totalIncome = 0;
    double totalExpense = 0;
    int transactionCount = _mockFinanceReports.length;
    for (final t in _mockFinanceReports) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    double balance = totalIncome - totalExpense;
    return FinanceSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
    );
  }

  // Finance View
  Future<List<FinanceReport>> getFinanceTransactions({Map<String, String?>? filters}) async {
    if (simulateDelay) await _delay();
    List<FinanceReport> result = List.from(_mockFinanceReports);
    if (filters != null && filters['type'] != null) {
      result = result.where((t) => t.type == filters['type']).toList();
    }
    return result;
  }

  // Banner Management
  Future<List<BannerModel>> getBanners({String? type}) async {
    if (simulateDelay) await _delay();
    if (type != null) {
      return _mockBanners.where((b) => b.type == type && b.isActive).toList();
    }
    return _mockBanners.where((b) => b.isActive).toList();
  }

  // Problem Reports Management
  Future<List<ProblemReport>> getProblemReports({String? status}) async {
    if (simulateDelay) await _delay();
    if (status != null) {
      return _mockProblemReports.where((r) => r.status == status).toList();
    }
    return _mockProblemReports;
  }

  // Letter Requests Management
  Future<List<LetterRequest>> getLetterRequests({String? status}) async {
    if (simulateDelay) await _delay();
    if (status != null) {
      return _mockLetterRequests.where((r) => r.status == status).toList();
    }
    return _mockLetterRequests;
  }

  // Residents Management
  Future<List<Map<String, dynamic>>> getResidents({String? status, String? search}) async {
    if (simulateDelay) await _delay();
    List<Map<String, dynamic>> result = List.from(_mockResidents);
    
    if (status != null) {
      result = result.where((r) => r['status'] == status).toList();
    }
    
    if (search != null && search.isNotEmpty) {
      result = result.where((r) {
        final name = r['name'].toString().toLowerCase();
        final nik = r['nik'].toString().toLowerCase();
        final searchLower = search.toLowerCase();
        return name.contains(searchLower) || nik.contains(searchLower);
      }).toList();
    }
    
    return result;
  }
}

