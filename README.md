# Lab SePay Payment — Flutter & VietQR

**Môn:** Lập trình Mobile  
**Đề bài:** Tích hợp thanh toán SePay với Flutter & VietQR  
**Thời gian lab:** 150 phút | **Tổng điểm:** 10.0

Ứng dụng Flutter tích hợp cổng thanh toán [SePay](https://sepay.vn) và mã QR chuyển khoản [VietQR](https://www.vietqr.io/), xác nhận giao dịch bằng **Polling API**.

---

## Mục tiêu

- Hiểu luồng SePay + VietQR
- Sinh mã QR chuyển khoản tự động
- Polling API xác nhận thanh toán
- Xử lý lỗi và hoàn thiện UI thanh toán QR

---

## Yêu cầu môi trường

| Yêu cầu | Ghi chú |
|---------|---------|
| Flutter SDK ≥ 3.0 | Đã test Flutter 3.41+ |
| Tài khoản SePay | [sepay.vn](https://sepay.vn) — có thể dùng Test mode |
| API Key SePay | Tạo tại Dashboard → API Access |
| Thiết bị test | **Android/iOS hoặc Emulator** — không dùng Flutter Web (CORS) |

**Dependencies:** `http`, `qr_flutter`, `flutter_dotenv`

---

## Cài đặt & chạy

```bash
git clone https://github.com/Kangnahyun23/LAB_SEPAY_PAYMENT.git
cd LAB_SEPAY_PAYMENT
flutter pub get
flutter run
```

### Cấu hình SePay

1. Copy [`.env.example`](.env.example) → `.env`
2. Điền `SEPAY_API_KEY`, `ACCOUNT_NO`, `ACCOUNT_BANK_ID`, … từ SePay Dashboard (Test mode)
3. Đặt `SEPAY_RUN_MODE=sandbox`, thêm `.env` vào `pubspec.yaml` (assets), chạy `flutter pub get`

Chi tiết biến môi trường xem trong file [`.env.example`](.env.example).

> Không commit file `.env` (đã có trong `.gitignore`).

---

## Cấu trúc project

```
lib/
├── main.dart
├── constants.dart              # AppConstants — cấu hình lab
├── config/app_config.dart      # Đọc .env
├── screens/
│   ├── payment_screen.dart     # Màn QR + polling
│   └── success_screen.dart     # Màn thành công
├── services/
│   ├── sepay_service.dart      # Gọi SePay API
│   └── mock_sepay_service.dart
├── utils/
│   ├── order_helper.dart       # Order ID + URL VietQR
│   └── format_helper.dart
├── widgets/                    # UI SePay / chuyển khoản QR
└── theme/sepay_theme.dart
```

---

## Nội dung 4 bài tập

| Bài | Điểm | Nội dung chính |
|-----|------|----------------|
| **1** | 2.0 | Khởi tạo Flutter, dependency, cấu trúc thư mục, `constants.dart` |
| **2** | 2.5 | `generateOrderId()`, `generateVietQR()`, hiển thị QR VietQR |
| **3** | 3.5 | `SepayService.checkPayment()`, Timer polling 5s, timeout 300s, `SuccessScreen` |
| **4** | 2.0 | Timeout HTTP 10s, countdown, loading, xử lý lỗi mạng, huỷ timer trong `dispose()` |

### Luồng thanh toán

```
Tạo Order ID → Sinh QR VietQR → User quét/chuyển khoản
       → Polling SePay API (5s/lần) → Khớp orderId + amount → Màn thành công
```

### API SePay (Polling)

```
GET https://my.sepay.vn/userapi/transactions/list?account_bank_id=...&limit=20
Header: Authorization: Bearer <API_KEY>
```

Khớp giao dịch: `transaction_content.contains(orderId)` và `amountIn >= amount`.

### VietQR

```
https://img.vietqr.io/image/{BANK_ID}-{ACCOUNT_NO}-compact2.png
  ?amount=...&addInfo=...&accountName=...
```

---

## Câu hỏi tự luận

### Bài 2 — URL encode Order ID trong `addInfo`?

Order ID truyền qua query parameter URL. Không `Uri.encodeComponent` thì ký tự đặc biệt (`&`, `=`, `?`, `%`, `#`, khoảng trắng) bị hiểu nhầm là phân tách URL, làm sai URL hoặc sai nội dung chuyển khoản trên QR.

### Bài 3.1 — Vì sao `cancel()` timer trong `dispose()`?

`Timer.periodic` chạy ngầm đến khi bị huỷ. Quên `cancel()` → `setState()` trên State đã dispose → crash / memory leak, request HTTP vẫn tiếp tục chạy.

### Bài 3.2 — `amountIn == amount` vs `amountIn >= amount`?

`>=` tốt hơn: user có thể chuyển thừa (10.500 thay vì 10.000). Dùng `==` dễ bỏ sót giao dịch hợp lệ.

---

## Checklist nộp bài

| Bài | Bằng chứng cần nộp |
|-----|-------------------|
| 1 | Ảnh `flutter run`, cấu trúc thư mục, `pubspec.yaml`, `constants.dart` |
| 2 | Ảnh QR trên thiết bị, ảnh quét app ngân hàng, `order_helper.dart`, `payment_screen.dart` |
| 3 | **Video** luồng QR → chuyển khoản → thành công; `sepay_service.dart`, `success_screen.dart` |
| 4 | Ảnh countdown + loading; video flight mode; toàn bộ source |

---

## Tác giả

Lab thực hành PRM393 — SePay Payment Integration
