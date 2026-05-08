// âœ… WEB VE MOBÄ°L Ä°STÄ°SNASINI YÃ–NETEN YARDIMCI
// Bu dosya, platforma gÃ¶re doÄŸru implementasyonu seÃ§er.

export 'geocoding_mobile.dart'
    if (dart.library.html) 'geocoding_web.dart'
    if (dart.library.js_util) 'geocoding_web.dart';
