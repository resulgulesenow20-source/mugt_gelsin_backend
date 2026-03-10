# Mugt Gelsin Bakım Kılavuzu

Bu dosya, sistemin kararlı bir şekilde çalışmaya devam etmesi için gereken adımları içerir.

## 🚀 Sistemi Başlatma
Uygulamanın tam fonksiyonel çalışması için iki bileşenin de açık olması gerekir:

1. **Backend (Sunucu)**: `start_backend_persistent.bat` dosyasını çalıştırın. Bu dosya sunucu çökerse otomatik olarak yeniden başlatır.
2. **Dashboard (Masaüstü)**: `main.py` dosyasını (veya derlenmiş EXE'yi) çalıştırın.

## 💾 Veri Yedekleme
Verileriniz iki yerde tutulur:

- **Yerel Veritabanı**: `restaurant.db` dosyası ürün, sipariş ve ayarlarınızı tutar.
- **Dükkan Profilleri**: `shops/` klasörü dükkan detaylarını ve menülerini tutar.

**Öneri**: Haftalık olarak `shops/` ve `restaurant.db` dosyalarınızın bir kopyasını alıp başka bir klasöre yedekleyin.

## 🛠️ Kod Güvenliği (Git)
Projenize **Git** entegrasyonu yapılmıştır. Kodlarınızda büyük bir değişiklik yapıp bozarsanız, şu komutla eski stabil haline dönebilirsiniz:
```bash
git checkout .
```

Yeni bir şey eklediğinizde ve çalıştığından emin olduğunuzda şu komutla "kaydedin":
```bash
git add .
git commit -m "Yeni bir özellik eklendi"
```

## 🔍 Sorun Giderme
- **Mobil uygulama dükkanı görmüyor**: Backend'in açık olduğundan ve doğru IP adresine (`172.20.10.2` vb.) bağlı olduğundan emin olun.
- **Uygulama donuyor**: İnternet bağlantınızı kontrol edin. Yeni güncellemelerle donma sorunları büyük ölçüde giderilmiştir.
