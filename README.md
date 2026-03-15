<div align="center">

# 🧩 Puzzleton

### Türkçe Kelime Bul Oyunu

Modern, animasyonlu ve tamamen Türkçe bir kelime arama bulmacası.
Flutter ile geliştirildi — Web, Android ve iOS'ta çalışır.

[🎮 Canlı Demo](https://ckaemm.github.io/puzzleton/) · [📱 Kurulum](#-kurulum) · [🛠 Teknik Detaylar](#-teknik-detaylar)

---

</div>

## 🎯 Proje Hakkında

Puzzleton, harf ızgarasında gizlenmiş Türkçe kelimeleri parmakla sürükleyerek bulan bir bulmaca oyunudur. 6 farklı kategoride 68 kelime, 3 zorluk seviyesi, ipucu sistemi ve ses efektleri ile zengin bir oyun deneyimi sunar.

## ✨ Özellikler

- **Harf Izgarası** — 10×10 ve 12×12 dinamik ızgara, kelimeler yatay, dikey ve çapraz yerleştirilir
- **Sürükle & Bul** — Parmakla veya fare ile sürükleyerek kelime seçme, 8 yönde arama
- **6 Kategori, 68 Kelime** — Hayvanlar, Şehirler, Meslekler, Yiyecekler, Doğa, Spor
- **3 Zorluk Seviyesi** — Kolay (3 dk, 6 kelime), Orta (2 dk, 10 kelime), Zor (1 dk, 14 kelime)
- **Skor Sistemi** — Kelime uzunluğuna göre puan, zorluk çarpanı, süre bonusu
- **İpucu Sistemi** — 3 hak, rastgele bir kelimenin harfini altın rengiyle vurgular
- **Ses Efektleri** — Web Audio API ile kelime bulma, ipucu, zafer ve süre dolma melodileri
- **Animasyonlar** — Kelime bulunca büyüme/küçülme efekti, ipucu hücreleri nabız animasyonu
- **Skor Tablosu** — Oyuncu adıyla skorlar kaydedilir, ilk 3'e altın/gümüş/bronz ikon
- **Dark Theme** — Turkuaz renk paletli modern Material Design 3 arayüz

## 🎮 Oynanış

1. Oyuncu adını gir
2. Zorluk seviyesini seç
3. Izgarada gizlenmiş kelimeleri bul — parmağını/fareyi sürükle
4. Bulunan kelimeler renkle vurgulanır ve listeden çizilir
5. Takıldığında 💡 İpucu butonunu kullan
6. Süre bitmeden tüm kelimeleri bul ve en yüksek skoru yap!

## 🚀 Kurulum

**Gereksinimler:** Flutter SDK 3.10+

```bash
# Repoyu klonla
git clone https://github.com/ckaemm/puzzleton.git
cd puzzleton

# Bağımlılıkları yükle
flutter pub get

# Web'de çalıştır
flutter run -d chrome

# Android'de çalıştır
flutter run

# Release build (web)
flutter build web --base-href "/puzzleton/"
```

## 🛠 Teknik Detaylar

### Mimari

```
lib/
├── main.dart                  # Uygulama giriş noktası
├── theme/
│   └── app_theme.dart         # Dark theme, turkuaz palet, Material 3
├── constants/
│   └── word_data.dart         # 6 kategori, 68 Türkçe kelime
├── models/
│   ├── game_config.dart       # Zorluk seviyesi yapılandırması
│   ├── placed_word.dart       # Izgara kelime pozisyon modeli
│   └── player_score.dart      # Skor modeli (JSON serialization)
├── services/
│   ├── grid_service.dart      # Kelime yerleştirme algoritması
│   ├── game_manager.dart      # Oyun durumu yönetimi (ChangeNotifier)
│   ├── score_service.dart     # SharedPreferences ile skor CRUD
│   └── sound_service.dart     # Web Audio API ses efektleri
├── screens/
│   ├── welcome_screen.dart    # Oyuncu adı giriş ekranı
│   ├── home_screen.dart       # Ana menü, zorluk seçimi
│   ├── game_screen.dart       # Oyun ekranı
│   ├── result_screen.dart     # Oyun sonu skor ekranı
│   └── leaderboard_screen.dart # Liderlik tablosu
└── widgets/
    ├── puzzle_grid.dart       # İnteraktif harf ızgarası
    ├── word_list_panel.dart   # Bulunacak kelime listesi
    └── game_timer.dart        # Geri sayım zamanlayıcı
```

### Kelime Yerleştirme Algoritması

Kelimeler 8 yönde (yatay, dikey, 4 çapraz) ızgaraya yerleştirilir. Uzun kelimeler önce yerleştirilir, çakışan harfler ortak kullanılabilir. Boş kalan hücreler rastgele Türkçe harflerle doldurulur.

### Sürükleme Mekaniği

`GestureDetector` ile `onPanStart/Update/End` olayları yakalanır. Sürükleme yönü en yakın 45°'ye snap edilir (yatay, dikey veya çapraz). `GlobalKey` ile ızgara pozisyonu hesaplanarak hangi hücrenin seçildiği belirlenir.

### Durum Yönetimi

`ChangeNotifier` + `ListenableBuilder` pattern'i ile sıfır bağımlılık durum yönetimi. `GameManager` sınıfı oyun durumunu, zamanlayıcıyı, skoru ve ipucu sistemini yönetir.

### Ses Sistemi

`dart:js_util` ile doğrudan Web Audio API `AudioContext` → `OscillatorNode` → `GainNode` zinciri kurulur. Harici dosya veya paket gerektirmez. Her ses efekti nota dizisi olarak tanımlanır.

## 📦 Bağımlılıklar

| Paket | Versiyon | Kullanım |
|-------|----------|----------|
| `flutter` | SDK | UI framework |
| `shared_preferences` | ^2.2.2 | Oyuncu adı ve skor kaydetme |

> Dışarıdan sadece 1 paket — minimal bağımlılık prensibi.

## 📄 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır.

---

<div align="center">

**Flutter** ile ❤️ ile geliştirildi

</div>
