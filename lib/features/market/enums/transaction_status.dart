/// Transaction status enum based on backend specification
/// Backend format: UPPERCASE with UNDERSCORE
/// 
/// Reference: BACKEND_RESPONSE_TRANSACTION_STATUS.md
enum TransactionStatus {
  belumDibayar('BELUM_DIBAYAR', 'Belum Dibayar'),
  proses('PROSES', 'Proses'),
  siapDiambil('SIAP_DIAMBIL', 'Siap Diambil'),
  sedangDikirim('SEDANG_DIKIRIM', 'Sedang Dikirim'),
  selesai('SELESAI', 'Selesai'),
  ditolak('DITOLAK', 'Ditolak');

  /// Backend value format (UPPERCASE with UNDERSCORE) - used for API communication
  final String backendValue;
  
  /// Display text for UI (readable format)
  final String displayText;

  const TransactionStatus(this.backendValue, this.displayText);

  /// Parse from backend response
  static TransactionStatus fromBackend(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.backendValue == value,
      orElse: () => TransactionStatus.belumDibayar,
    );
  }

  /// Parse from display text (for backward compatibility)
  static TransactionStatus fromDisplayText(String text) {
    return TransactionStatus.values.firstWhere(
      (status) => status.displayText == text,
      orElse: () => TransactionStatus.belumDibayar,
    );
  }

  /// Get next status in the workflow
  TransactionStatus? getNextStatus() {
    switch (this) {
      case TransactionStatus.belumDibayar:
        return TransactionStatus.proses;
      case TransactionStatus.proses:
        return TransactionStatus.siapDiambil;
      case TransactionStatus.siapDiambil:
        return TransactionStatus.sedangDikirim;
      case TransactionStatus.sedangDikirim:
        return TransactionStatus.selesai;
      case TransactionStatus.selesai:
      case TransactionStatus.ditolak:
        return null; // Final states, cannot transition
    }
  }

  /// Check if status can be updated
  bool get canBeUpdated {
    return this != TransactionStatus.selesai && this != TransactionStatus.ditolak;
  }

  /// Check if status is active (not completed/rejected)
  bool get isActive {
    return this == TransactionStatus.belumDibayar ||
           this == TransactionStatus.proses ||
           this == TransactionStatus.siapDiambil ||
           this == TransactionStatus.sedangDikirim;
  }

  /// Check if status is final (completed or rejected)
  bool get isFinal {
    return this == TransactionStatus.selesai || this == TransactionStatus.ditolak;
  }
}
