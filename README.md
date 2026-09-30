# Factory Boss

Factory Boss, Android öncelikli bir 2D idle/factory management MVP’sidir. Flutter ile arayüz, Flame ile gerçek zamanlı fabrika sahnesi oluşturulmuştur. Haricî görsel veya ses asset’i gerektirmez; bütün fabrika grafikleri hafif vektör şekillerle çizilir.

## Mevcut özellikler

- Çalışan CNC Lathe ile zaman tabanlı üretim
- Hareketli conveyor ve depoya giden ürün animasyonu
- Otomatik satış, nakit animasyonu ve ölçeklenen ekonomi
- Makine level, hız, parça değeri, reliability ve upgrade maliyeti
- Nadir makine arızası, ücretli tamir ve mock rewarded-ad ile ücretsiz tamir
- Kapasiteli warehouse; depo dolduğunda üretimin durması
- Warehouse ve satış hızı upgrade’leri
- Factory Level, XP ve level ile açılan dört makine:
  - Level 1: CNC Lathe
  - Level 3: Drill Press
  - Level 5: CNC Milling
  - Level 8: Packaging Machine
- Operator, Mechanic ve Supervisor çalışan bonusları
- Üretim, upgrade, gelir ve tamir görevleri
- First Upgrade, 1,000 Parts, Factory Level 10 ve Millionaire achievement’ları
- SharedPreferences tabanlı otomatik cihaz kaydı
- En fazla 4 saatlik offline üretim ve gelir özeti
- Music, Sound Effects, Vibration, Notifications ve Reset Progress ayarları
- Mock 10 dakikalık 2x gelir ödüllü reklamı; zorunlu reklam yoktur
- Asset bulunmadığında crash oluşturmayacak boş ses servisi
- Android debug APK üreten GitHub Actions iş akışı

Ekonomi değerleri ve makine kataloğu [`lib/utils/config.dart`](lib/utils/config.dart) dosyasından değiştirilebilir. Upgrade maliyeti varsayılan olarak `baseCost × 1.15^(level-1)` formülünü kullanır.

## Proje yapısı

```text
lib/
├── main.dart
├── game/
│   ├── factory_game.dart
│   └── components/       # Makine, conveyor, ürün ve depo çizimleri
├── models/               # Player, machine ve mission verileri
├── systems/              # Ekonomi, offline ilerleme ve ana controller
├── screens/              # Factory, upgrades, missions, shop, settings
├── services/             # Save, güvenli ses ve mock reklam adaptörleri
├── theme/
└── utils/config.dart
test/                     # Ekonomi ve offline ilerleme testleri
android/                  # Android uygulama/manifest yapılandırması
.github/workflows/android.yml
```

## Yalnızca Android telefonla APK alma

Bilgisayar gerekmez. GitHub Android uygulamasını veya telefon tarayıcısını kullanabilirsiniz.

1. Proje dosyalarını bir GitHub repository’sine yükleyin ve varsayılan branch’e push edin.
2. Repository sayfasında **Actions** sekmesini açın.
3. İlk kullanımda istenirse **I understand my workflows, go ahead and enable them** seçeneğine dokunun.
4. **Factory Boss Android** workflow’unu seçin.
5. Her push build’i otomatik başlatır. Manuel build için **Run workflow → Run workflow** kullanın.
6. Yeşil onay işareti gelince workflow çalışmasını açın.
7. Sayfanın altındaki **Artifacts** bölümünden **Factory-Boss-Android** dosyasını indirin.
8. İnen ZIP’i telefonun Dosyalar uygulamasıyla açın ve `app-debug.apk` dosyasına dokunun.
9. Android isterse bu tarayıcı/Dosyalar uygulaması için **Bilinmeyen uygulamaları yükle** iznini açın. Ardından APK’yı kurun.

Workflow sırasıyla şunları çalıştırır:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

APK yolu: `build/app/outputs/flutter-apk/app-debug.apk`

Artifact adı: `Factory-Boss-Android`

> Debug APK test içindir. Google Play yayını için ileride release imzalama anahtarı ve `appbundle --release` adımı eklenmelidir. İmzalama anahtarını repository’ye yüklemeyin; GitHub Actions Secrets kullanın.

## Telefondan kod düzenleme

- Küçük değişiklikler: GitHub dosya görünümündeki kalem simgesiyle düzenleyip commit oluşturun.
- Birden fazla dosya: Tarayıcıda repository adresindeki `github.com` kısmını `github.dev` olarak değiştirin. Bu mobil web editörü kurulum istemeden commit/push yapabilir.
- Ekonomi ayarı: `lib/utils/config.dart`
- Makine değerleri/açılma seviyeleri: aynı dosyadaki `MachineCatalog`
- Görevler: `lib/models/mission_model.dart`

Her commit yeni APK build’ini otomatik başlatır. Telefonda Flutter SDK, Android Studio veya bilgisayar kurulumu gerekmez.

## Build hatalarını telefondan bulma

1. GitHub’da **Actions → Factory Boss Android** bölümünü açın.
2. Kırmızı işaretli workflow çalışmasına dokunun.
3. **build-android** job’unu, ardından kırmızı adımı (`Analyze`, `Test` veya `Build debug APK`) açın.
4. Log içinde `Error`, `FAILURE`, `lib/...dart:<satır>` veya `AndroidManifest.xml` ifadelerini arayın.
5. Dosya ve satır numarasını `github.dev` üzerinden düzeltip commit edin. Yeni build otomatik başlar.

Uygulama telefonda açılıp kapanıyorsa bilgisayarsız iki seçenek vardır:

- **Ayarlar → Uygulamalar → Factory Boss** üzerinden depolamayı temizleyip yeniden deneyin.
- İleri seviye teşhis için Termux ve Android’in kablosuz hata ayıklama özelliğiyle `adb logcat` kullanılabilir. Normal build/kurulum için Termux gerekli değildir.

## Kayıt ve offline ilerleme

Oyun yaklaşık 10 saniyede bir ve uygulama arka plana alınırken kayıt yapar. Cash, level/XP, makine durumları, warehouse/sales/worker seviyeleri, görevler, toplam üretim, ayarlar ve son giriş zamanı cihazda tutulur. Uygulama geri açıldığında geçen süre en fazla 4 saat olarak hesaplanır. Reset Progress işlemi geri alınamaz.

## Sonraki geliştirme önerileri

1. Gerçek ses dosyalarını `AudioService` arkasına bağlamak.
2. Laser Cutter, Robot Arm, Press, Welding, Grinding ve Painting istasyonlarını kataloğa eklemek.
3. Ürün türüne göre ayrı stok ve satış fiyatı oluşturmak.
4. Achievement ekranını, günlük görevleri ve fabrika bölgelerini eklemek.
5. Gerçek rewarded ads sağlayıcısını `AdService` arkasına bağlamak.
6. Google Play Games/cloud save ve bildirim desteği eklemek.
7. Release keystore’u GitHub Secrets ile yapılandırıp imzalı AAB üretmek.
8. Düşük segment cihazlarda frame-time ve batarya profil testi yapmak.

## Lisans ve gizlilik notu

MVP gerçek reklam, ödeme, analytics veya ağ isteği içermez. SharedPreferences kayıtları yalnızca cihazda saklanır.
