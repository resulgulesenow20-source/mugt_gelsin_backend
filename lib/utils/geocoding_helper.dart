// ✅ WEB VE MOBİL İSTİSNASINI YÖNETEN YARDIMCI
// Bu dosya, platforma göre doğru implementasyonu seçer.

export 'geocoding_mobile.dart'
    if (dart.library.html) 'geocoding_web.dart';
