# 🐛 Bug Report: Transaction Status Inconsistency - CRITICAL

## Masalah Utama
Backend memiliki **inconsistency** antara validation pattern dan database enum untuk transaction status, menyebabkan:
1. ❌ Semua UPDATE status gagal (error 422 atau 500)
2. ❌ GET endpoint gagal read data dengan status English (error 500)
3. ❌ Database memiliki data corrupted dengan nilai English yang tidak valid

## Root Cause Analysis

### 1. Database Enum (Indonesian)
```python
class TransactionStatusEnum(str, enum.Enum):
    BELUM_DIBAYAR = "Belum Dibayar"
    PROSES = "Proses"
    SIAP_DIAMBIL = "Siap Diambil"
    SEDANG_DIKIRIM = "Sedang Dikirim"
    SELESAI = "Selesai"
    DITOLAK = "Ditolak"
```

### 2. API Validation Pattern (English) ❌
Current validation di endpoint PUT `/marketplace/transactions/{id}/status`:
```python
pattern='^(processing|shipping|completed|cancelled)$'
```

### 3. Database Contains English Values ❌
Ada data di database dengan status English: `"processing"`, `"shipping"`, `"completed"`  
**Ini INVALID** karena enum hanya terima Indonesian values!

## Error Scenarios

### Error 1: UPDATE Status (422/500)
```
Frontend sends "Proses" 
    ↓
API Validation: ❌ 422 Error 
    → Pattern expects: "processing" 
    → Received: "Proses"

Frontend sends "processing" (after trying English)
    ↓
API Validation: ✅ Passes
    ↓
Database Insert: ❌ 500 Error
    → Enum expects: "Proses"
    → Received: "processing"
```

### Error 2: GET Transactions (500)
```
GET /marketplace/transactions?user_id=xxx
    ↓
Database Query: Find all transactions
    ↓
Result includes transaction with status="shipping"
    ↓
Enum Mapper: ❌ 500 Error
    → LookupError: 'shipping' is not among defined enum values
    → Cannot serialize response
```

## 🎯 Required Fixes (URGENT)

### Fix 1: Clean Corrupted Data in Database
Ada data dengan status English yang tidak valid. **HARUS dibersihkan dulu!**

```sql
-- Check for corrupted data
SELECT product_transaction_id, status 
FROM t_product_transaction 
WHERE status IN ('processing', 'shipping', 'completed', 'cancelled', 'pending');

-- Fix corrupted data (run with caution!)
UPDATE t_product_transaction SET status = 'Proses' WHERE status = 'processing';
UPDATE t_product_transaction SET status = 'Sedang Dikirim' WHERE status = 'shipping';
UPDATE t_product_transaction SET status = 'Selesai' WHERE status = 'completed';
UPDATE t_product_transaction SET status = 'Ditolak' WHERE status = 'cancelled';
UPDATE t_product_transaction SET status = 'Belum Dibayar' WHERE status = 'pending';

-- Verify all status values are valid
SELECT DISTINCT status FROM t_product_transaction;
-- Should only return: Belum Dibayar, Proses, Sedang Dikirim, Selesai, Ditolak
```

### Fix 2: Update API Validation Pattern

File: `backend_jawara/src/marketplace/controller.py` atau schema file

**SEBELUM:**
```python
class UpdateTransactionStatusRequest(BaseModel):
    status: str = Field(..., pattern=r'^(processing|shipping|completed|cancelled)$')
```

**SESUDAH:**
```python
class UpdateTransactionStatusRequest(BaseModel):
    status: str = Field(..., pattern=r'^(Proses|Sedang Dikirim|Selesai|Ditolak)$')
    
    # Atau lebih flexible dengan validator
    @field_validator('status')
    def validate_status(cls, v):
        allowed = ["Proses", "Sedang Dikirim", "Selesai", "Ditolak"]
        if v not in allowed:
            raise ValueError(f'Status must be one of: {", ".join(allowed)}')
        return v
```

### Fix 3: Add Enum Value Validation in Service Layer (RECOMMENDED)

Tambahkan validation sebelum insert/update ke database untuk prevent future corruption:

```python
# In service.py
def update_transaction_status(db, transaction_id, user_id, status_data):
    # Validate against enum values
    try:
        valid_status = TransactionStatusEnum(status_data.status)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Allowed: {[e.value for e in TransactionStatusEnum]}"
        )
    
    transaction = db.query(ProductTransactionModel).filter(
        ProductTransactionModel.product_transaction_id == uuid_lib.UUID(transaction_id)
    ).first()
    
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    transaction.status = valid_status
    db.commit()
    db.refresh(transaction)
    
    return transaction
```

## ✅ Validation Pattern yang Benar

Harus match dengan enum values:
```python
ALLOWED_STATUS = ["Proses", "Sedang Dikirim", "Selesai", "Ditolak"]
# Tidak termasuk "Belum Dibayar" karena itu status awal, tidak bisa diubah manual
```

## 📝 Testing Checklist

### Pre-Test: Verify Database Cleanup
```bash
# Check no English values remain
curl "http://localhost:8000/marketplace/transactions?user_id={any_user_id}&limit=100"
# All status values should be Indonesian
```

### Test 1: GET Transactions (Should work after cleanup)
```bash
curl "http://localhost:8000/marketplace/transactions?user_id={buyer_id}"
```
Expected: ✅ 200 OK with list of transactions

### Test 2: GET Seller Transactions
```bash
curl "http://localhost:8000/marketplace/transactions/sales?user_id={seller_id}&type=active"
```
Expected: ✅ 200 OK with list of transactions

### Test 3: Update Belum Dibayar → Proses
```bash
curl -X PUT "http://localhost:8000/marketplace/transactions/{id}/status?user_id={seller_id}" \
  -H "Content-Type: application/json" \
  -d '{"status": "Proses"}'
```
Expected: ✅ 200 OK

### Test 4: Update Proses → Sedang Dikirim
```bash
curl -X PUT "http://localhost:8000/marketplace/transactions/{id}/status?user_id={seller_id}" \
  -H "Content-Type: application/json" \
  -d '{"status": "Sedang Dikirim"}'
```
Expected: ✅ 200 OK

### Test 5: Update Sedang Dikirim → Selesai
```bash
curl -X PUT "http://localhost:8000/marketplace/transactions/{id}/status?user_id={seller_id}" \
  -H "Content-Type: application/json" \
  -d '{"status": "Selesai"}'
```
Expected: ✅ 200 OK

### Test 6: Invalid Status (English)
```bash
curl -X PUT "http://localhost:8000/marketplace/transactions/{id}/status?user_id={seller_id}" \
  -H "Content-Type: application/json" \
  -d '{"status": "processing"}'
```
Expected: ❌ 400/422 with clear error message

## 🔍 Files to Check

1. `backend_jawara/src/marketplace/controller.py` - Endpoint definition
2. `backend_jawara/src/marketplace/schema.py` - Pydantic models (jika ada)
3. `backend_jawara/src/marketplace/service.py` - Business logic
4. `backend_jawara/src/marketplace/models.py` - Database enum

## ⚠️ Important Notes

1. **Konsistensi**: Semua layer harus gunakan Bahasa Indonesia
   - Database enum: ✅ Indonesian
   - API validation: ❌ English (FIX THIS)
   - API response: ✅ Indonesian
   - Frontend display: ✅ Indonesian

2. **Flow Status** yang valid:
   ```
   Belum Dibayar (initial) 
        ↓
   Proses (seller confirms payment)
        ↓
   Sedang Dikirim (seller ships order)
        ↓
   Selesai (buyer receives order)
   ```

3. **Special Status**:
   - `Ditolak`: Admin/seller can reject order
   - `Belum Dibayar`: Initial status, tidak perlu di validation pattern

## � Critical Impact

### Current Blocked Features:
1. ❌ **"Kelola Transaksi"** - Seller cannot update transaction status
2. ❌ **"Pesanan Saya"** - Buyer cannot view their orders (500 error)
3. ❌ **Transaction Management** - Completely non-functional
4. ❌ **Order Tracking** - Cannot display order status

### Database Corruption Status:
```
ERROR: LookupError: 'shipping' is not among the defined enum values
```
Ini berarti ada data dengan nilai English di database yang tidak bisa di-read!

## 💡 Alternative Solution (NOT RECOMMENDED)

Jika ingin tetap menggunakan English untuk API (not recommended karena inconsistent):

```python
# Add bidirectional mapping in service layer
STATUS_TO_INDONESIAN = {
    "processing": "Proses",
    "shipping": "Sedang Dikirim", 
    "completed": "Selesai",
    "cancelled": "Ditolak",
    "pending": "Belum Dibayar"
}

STATUS_TO_ENGLISH = {v: k for k, v in STATUS_TO_INDONESIAN.items()}

def update_transaction_status(db, transaction_id, user_id, status_data):
    # Map English to Indonesian before database update
    english_status = status_data.status
    indonesian_status = STATUS_TO_INDONESIAN.get(english_status)
    
    if not indonesian_status:
        raise ValueError(f"Invalid status: {english_status}")
    
    # Update database with Indonesian status
    transaction.status = TransactionStatusEnum(indonesian_status)
    db.commit()

# Also need to update serialization to convert back to English if needed
```

**⚠️ WARNING:** This approach adds complexity and maintenance burden. **Recommended to use Indonesian everywhere for consistency.**

## Current Frontend State

Frontend sudah handle untuk mengirim Indonesian status sesuai database enum. Setelah backend fix validation pattern, semua harusnya work perfectly.

## 📋 Action Items (Priority Order)

### 🔥 URGENT - Must Fix First:
1. **Clean corrupted data in database** (SQL UPDATE queries above)
   - Without this, GET endpoints will continue to crash
   - This is blocking all transaction views

### 🔥 CRITICAL - Fix Immediately After:
2. **Update API validation pattern** to use Indonesian
   - Change pattern from English to Indonesian
   - This enables UPDATE status functionality

### ⚠️ RECOMMENDED - Prevent Future Issues:
3. **Add enum validation in service layer**
   - Prevent invalid values from being inserted
   - Add clear error messages

### ✅ TESTING:
4. **Run all test cases** to verify fixes
   - Test GET endpoints don't crash
   - Test UPDATE endpoints accept Indonesian
   - Test validation rejects English

---

## Priority: 🔥🔥🔥 CRITICAL - PRODUCTION DOWN

### Impact:
- ❌ Marketplace completely non-functional
- ❌ Sellers cannot manage orders
- ❌ Buyers cannot view their orders
- ❌ All transaction features blocked

### Affected Endpoints:
1. `GET /marketplace/transactions` - **CRASHING** (500)
2. `GET /marketplace/transactions/sales` - **CRASHING** (500)
3. `PUT /marketplace/transactions/{id}/status` - **FAILING** (422/500)
4. `POST /marketplace/transactions/{id}/cancel` - May crash if status is English

### Root Cause:
Database contains English enum values (`"shipping"`, `"processing"`) but SQLAlchemy enum only accepts Indonesian values.

---

**Created:** December 16, 2025  
**Updated:** December 16, 2025  
**Reporter:** Frontend Team  
**Status:** 🚨 PRODUCTION CRITICAL - Awaiting Backend Fix  
**ETA Needed:** ASAP - Core marketplace features completely down
