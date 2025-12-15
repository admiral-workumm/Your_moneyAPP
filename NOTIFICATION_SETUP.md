# Sistem Notifikasi Pengingat - Your Money App

## 📱 Fitur yang Diimplementasikan

Sistem notifikasi lokal yang berfungsi untuk mengingatkan user mencatat pengeluaran mereka sesuai waktu yang telah diatur.

## 🔧 Library yang Digunakan

1. **flutter_local_notifications (v17.0.0)** - Untuk menampilkan notifikasi lokal
2. **timezone (v0.9.2)** - Untuk scheduling notifikasi berdasarkan zona waktu
3. **permission_handler (v11.0.1)** - Untuk meminta izin notifikasi ke user

## ⚙️ Cara Kerja

### 1. Initialization
Saat app dibuka, `NotificationService` akan diinisialisasi di `main.dart`:
- Setup timezone ke Asia/Jakarta
- Konfigurasi Android & iOS notification settings
- Request permission notifikasi dari user

### 2. Schedule Notification
Saat user menyimpan pengingat baru:
- Waktu harus diatur (tidak boleh 00:00)
- Notifikasi dijadwalkan berdasarkan periode:
  - **Harian**: Notifikasi muncul setiap hari pada waktu yang sama
  - **Mingguan**: Notifikasi muncul setiap minggu (default: Senin)
  - **Bulanan**: Notifikasi muncul setiap bulan (default: tanggal 1)
  - **Tahunan**: Notifikasi muncul setiap tahun (default: 1 Januari)

### 3. Toggle Notification
- Jika pengingat dinonaktifkan → notifikasi dibatalkan
- Jika pengingat diaktifkan kembali → notifikasi dijadwalkan ulang

### 4. Update Notification
Saat user mengubah waktu pengingat:
- Notifikasi lama dibatalkan
- Notifikasi baru dijadwalkan dengan waktu yang baru

### 5. Delete Notification
Saat pengingat dihapus → notifikasi juga otomatis dibatalkan

## 📋 Permissions yang Ditambahkan (Android)

Di `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## 🎯 Notification Channels

1. **daily_reminder_channel** - Untuk pengingat harian
2. **weekly_reminder_channel** - Untuk pengingat mingguan
3. **monthly_reminder_channel** - Untuk pengingat bulanan
4. **yearly_reminder_channel** - Untuk pengingat tahunan
5. **instant_notification_channel** - Untuk notifikasi instant (testing)

## 🔔 Konten Notifikasi

- **Title**: "Pengingat Keuangan"
- **Body**: "Jangan lupa catat pengeluaran Anda hari ini!"
- **Icon**: @mipmap/ic_launcher (icon aplikasi)
- **Sound**: Enabled
- **Vibration**: Enabled
- **Priority**: High

## 🧪 Testing

Untuk testing notifikasi tanpa menunggu waktu schedule:
```dart
NotificationService().showNotification(
  id: 999,
  title: 'Test Notifikasi',
  body: 'Ini notifikasi test',
);
```

## 📝 Catatan

1. Notifikasi akan tetap berjalan meskipun app ditutup
2. Notifikasi akan dijadwalkan ulang setelah device reboot (thanks to BOOT_COMPLETED receiver)
3. Untuk Android 13+ (API 33+), user akan diminta permission notifikasi saat pertama kali menggunakan fitur
4. Timezone di-set ke Asia/Jakarta secara default
5. Validasi waktu memastikan user harus mengatur waktu (tidak boleh 00:00) sebelum menyimpan

## 🚀 Cara Menggunakan

1. Buka halaman Pengingat
2. Tap tombol "+" untuk buat pengingat baru
3. Atur waktu dengan tap pada time picker
4. Pilih periode (Harian/Mingguan/Bulanan/Tahunan)
5. Tap "Simpan Pengingat"
6. Notifikasi akan muncul sesuai waktu yang diatur!

## 🐛 Troubleshooting

**Notifikasi tidak muncul?**
- Pastikan permission notifikasi sudah diizinkan
- Cek pengaturan notifikasi di settings device
- Pastikan battery optimization tidak membatasi app
- Untuk Android, pastikan "Exact alarm" permission diizinkan

**Notifikasi hilang setelah reboot?**
- BOOT_COMPLETED receiver sudah ditambahkan di AndroidManifest
- Pastikan app pernah dibuka minimal sekali setelah reboot
