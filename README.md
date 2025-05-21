# 📱 Tryout App (Flutter)

Aplikasi tryout berbasis Flutter yang terhubung dengan REST API.

---

## Fitur Utama

- Register & Login dengan API eksternal
- Splash screen & pengecekan token otomatis
- Tryout dinamis: soal dan jawaban dari API
- Navigasi bersih (tidak kembali ke splash/login)
- Skor dihitung otomatis
- Logout & simpan token dengan SharedPreferences

---

## Cara Menjalankan Aplikasi

### Pastikan Sudah Terinstall:

- [✔️ Flutter SDK](https://docs.flutter.dev/get-started/install)
- [✔️ VS Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio)
- [✔️ Android Emulator](https://developer.android.com/studio/run/emulator) atau perangkat HP


### Cek Flutter:

```bash
flutter --version
flutter doctor
```


### Clone Proyek: 

```bash
https://github.com/qdzxjtf/TryOut-Flutter
```


### Instalasi Dependency:

```bash
flutter pub get
```


### Ubah Tampilan Logo:
```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash
```


### Buka Emulator / Sambungkan Perangkat HP:
✅ Emulator (Android Studio / VS Code)

Jalankan Android Studio → klik Device Manager → klik ▶️ pada emulator.

Atau di VS Code, buka Command Palette Ctrl+Shift+P → Flutter: Launch Emulator.

✅ Atau Hubungkan HP Android via USB:

Aktifkan Developer Options dan USB Debugging.

Cek dengan:
```bash
flutter devices
```


### Jalankan Aplikasi:
```bash
flutter pub run
```

---


## Cara Penggunaan

- Registrasi akun

- Login

- Pilih Coba Try Out

- Hasil Tryout akan keluar jika sudah selesai mengerjakan
