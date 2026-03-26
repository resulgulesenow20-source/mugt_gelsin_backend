import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLang = 'TR'; // VarsayÄ±lan dil TÃ¼rkÃ§e
  
  String get selectedLang => _selectedLang;

  LanguageProvider() {
    _loadLanguage();
  }

  // KalÄ±cÄ± hafÄ±zadan dili yÃ¼kle
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLang = prefs.getString('selected_lang') ?? 'TR';
    notifyListeners();
  }

  // Dili deÄŸiÅŸtir ve kaydet
  Future<void> setLanguage(String langCode) async {
    _selectedLang = langCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_lang', langCode);
  }

  // Ã‡eviri Metinleri
  static final Map<String, Map<String, String>> translations = {
    'TR': {
      'app_name': 'mugut Gelsin',
      'tagline': 'Lezzete Bir AdÄ±m UzaklÄ±ktasÄ±nÄ±z',
      'login_button': 'GiriÅŸ Yap',
      'phone_label': 'Telefon NumarasÄ±',
      'phone_hint': 'Ã–rn: 5551234567',
      'no_account': 'HesabÄ±nÄ±z yok mu?',
      'signup': 'KayÄ±t Ol',
      'address_select': 'Adres SeÃ§in / Ekle',
      'highlights': 'Ã–ne Ã‡Ä±kanlar',
      'cheapest': 'En Ucuz Lezzetler',
      'restaurants': 'Restoranlar',
      'search_hint': 'Restoran veya yemek arayÄ±n...',
      'nav_home': 'Ana Sayfa',
      'nav_favorites': 'Favoriler',
      'nav_cart': 'Sepetim',
      'nav_profile': 'Profil',
      'products': 'ÃœrÃ¼nler',
      'no_fav_res': 'Favori restoran bulunamadÄ±!',
      'no_fav_prod': 'Favori Ã¼rÃ¼n bulunamadÄ±!',
      'nav_orders': 'SipariÅŸler',
      'orders': 'SipariÅŸlerim',
      'addresses': 'Adreslerim',
      'payment_methods': 'Ã–deme YÃ¶ntemlerim',
      'coupons': 'KuponlarÄ±m',
      'help_support': 'YardÄ±m & Destek',
      'mugut_support': 'mugut Destek',
      'logout': 'Ã‡Ä±kÄ±ÅŸ Yap',
      'logout_confirm_title': 'Ã‡Ä±kÄ±ÅŸ Yap',
      'logout_confirm_desc': 'HesabÄ±nÄ±zdan Ã§Ä±kÄ±ÅŸ yapmak istediÄŸinize emin misiniz?',
      'clear_cart': 'Sepeti BoÅŸalt',
      'clear_cart_confirm': 'Sepetindeki tÃ¼m Ã¼rÃ¼nleri silmek istediÄŸine emin misin?',
      'cancel': 'VazgeÃ§',
      'clear': 'BoÅŸalt',
      'empty_cart_msg': 'HenÃ¼z sepetinde Ã¼rÃ¼n yok!',
      'empty_cart_desc': 'Hemen lezzetli yemeklerden birini seÃ§\nve sepetini doldurmaya baÅŸla.',
      'start_shopping': 'AlÄ±ÅŸveriÅŸe BaÅŸla',
      'subtotal': 'Ara Toplam',
      'delivery_fee': 'GÃ¶nderim Ãœcreti',
      'service_fee': 'Hizmet Bedeli',
      'total_price': 'Toplam Tutar',
      'complete_order': 'SipariÅŸi Tamamla',
      'register_title': 'KayÄ±t Ol',
      'create_account': 'Yeni Hesap OluÅŸtur',
      'register_desc': 'AdÄ±nÄ±zÄ± ve telefon numaranÄ±zÄ± girerek kayÄ±t olun.',
      'full_name': 'Ad Soyad',
      'already_have_account': 'Zaten hesabÄ±nÄ±z var mÄ±?',
      'fill_all_fields': 'LÃ¼tfen tÃ¼m alanlarÄ± doldurun',
      'register_success': 'KayÄ±t baÅŸarÄ±lÄ±! GiriÅŸ yapÄ±lÄ±yor...',
      'register_failed': 'KayÄ±t baÅŸarÄ±sÄ±z',
      'phone_already_registered': 'Bu telefon numarasÄ± zaten kayÄ±tlÄ±. LÃ¼tfen giriÅŸ yapÄ±n.',
      'phone_not_registered': 'Bu numara kayÄ±tlÄ± deÄŸil. LÃ¼tfen Ã¶nce kayÄ±t olun.',
      'error': 'Hata',
    },
    'TM': {
      'app_name': 'mugut Gelsin',
      'tagline': 'Tagama Bir Ã„dim GaldyÅˆyz',
      'login_button': 'GiriÅŸ Et',
      'phone_label': 'Telefon Belgisi',
      'phone_hint': 'Meselem: 65123456',
      'no_account': 'HasabyÅˆyz Ã½okmy?',
      'signup': 'Hasap AÃ§',
      'address_select': 'Adres SaÃ½laÅˆ / GoÅŸuÅˆ',
      'highlights': 'MÃ¶hÃ¼m we MeÅŸhur',
      'cheapest': 'IÅˆ Arzan Tagamlar',
      'restaurants': 'Restoranlar',
      'search_hint': 'Restoran Ã½a-da tagam gÃ¶zlÃ¤Åˆ...',
      'nav_home': 'BaÅŸ Sahypa',
      'nav_favorites': 'Halanlarym',
      'nav_cart': 'Sebedim',
      'nav_profile': 'Profilim',
      'products': 'Ã–nÃ¼mler',
      'no_fav_res': 'HalanÃ½an restoran tapylmady!',
      'no_fav_prod': 'HalanÃ½an Ã¶nÃ¼m tapylmady!',
      'nav_orders': 'Sargytlar',
      'orders': 'Sargytlarym',
      'addresses': 'Adreslerim',
      'payment_methods': 'TÃ¶leg usullarym',
      'coupons': 'Kuponlarym',
      'help_support': 'KÃ¶mek we Goldaw',
      'mugut_support': 'mugut Goldaw',
      'logout': 'Hasapdan Ã§yk',
      'logout_confirm_title': 'Hasapdan Ã§yk',
      'logout_confirm_desc': 'HasabyÅˆyzdan Ã§ykmak isleÃ½Ã¤ndigiÅˆize ynanÃ½arsyÅˆyzmy?',
      'clear_cart': 'Sebedi boÅŸat',
      'clear_cart_confirm': 'SebediÅˆizdÃ¤ki Ã¤hli Ã¶nÃ¼mleri pozmak isleÃ½Ã¤ndigiÅˆize ynanÃ½arsyÅˆyzmy?',
      'cancel': 'Bes et',
      'clear': 'Poz',
      'empty_cart_msg': 'SebediÅˆizde entek Ã¶nÃ¼m Ã½ok!',
      'empty_cart_desc': 'HÃ¤zir lezzetli tagamlaryÅˆ birini saÃ½laÅˆ\nwe sebediÅˆizi doldurmaga baÅŸlaÅˆ.',
      'start_shopping': 'SÃ¶wda baÅŸla',
      'subtotal': 'Jemi',
      'delivery_fee': 'Eltip bermek tÃ¶legi',
      'service_fee': 'Hyzmat tÃ¶legi',
      'total_price': 'Umumy baha',
      'complete_order': 'Sargydy tamamla',
      'register_title': 'Hasap AÃ§',
      'create_account': 'TÃ¤ze Hasap DÃ¶ret',
      'register_desc': 'AdyÅˆyzy we telefon belgiÅˆizi girizip hasap aÃ§yÅˆ.',
      'full_name': 'AdyÅˆyz we FamiliÃ½aÅˆyz',
      'already_have_account': 'HasabyÅˆyz barmy?',
      'fill_all_fields': 'Ehlisini dolduryÅˆ!',
      'register_success': 'Hasap aÃ§yldy! GiriÅŸ edilÃ½Ã¤r...',
      'register_failed': 'Hasap aÃ§ylmady',
      'phone_already_registered': 'Bu telefon belgisi eÃ½Ã½Ã¤m hasaba alnan.',
      'phone_not_registered': 'Bu telefon belgisi hasaba alynmadyk. Ilki bilen hasap aÃ§yÅˆ.',
      'error': 'SÃ¤wlik',
    },
    'RU': {
      'app_name': 'mugut Gelsin',
      'tagline': 'Ð’Ñ‹ Ð² Ð¾Ð´Ð½Ð¾Ð¼ ÑˆÐ°Ð³Ðµ Ð¾Ñ‚ Ð²ÐºÑƒÑÐ°',
      'login_button': 'Ð’Ð¾Ð¹Ñ‚Ð¸',
      'phone_label': 'ÐÐ¾Ð¼ÐµÑ€ Ñ‚ÐµÐ»ÐµÑ„Ð¾Ð½Ð°',
      'phone_hint': 'ÐŸÑ€Ð¸Ð¼: 5551234567',
      'no_account': 'ÐÐµÑ‚ Ð°ÐºÐºÐ°ÑƒÐ½Ñ‚Ð°?',
      'signup': 'Ð ÐµÐ³Ð¸ÑÑ‚Ñ€Ð°Ñ†Ð¸Ñ',
      'address_select': 'Ð’Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ / Ð”Ð¾Ð±Ð°Ð²Ð¸Ñ‚ÑŒ Ð°Ð´Ñ€ÐµÑ',
      'highlights': 'Ð ÐµÐºÐ¾Ð¼ÐµÐ½Ð´ÑƒÐµÐ¼Ð¾Ðµ',
      'cheapest': 'Ð¡Ð°Ð¼Ñ‹Ðµ Ð´ÐµÑˆÐµÐ²Ñ‹Ðµ Ð±Ð»ÑŽÐ´Ð°',
      'restaurants': 'Ð ÐµÑÑ‚Ð¾Ñ€Ð°Ð½Ñ‹',
      'search_hint': 'ÐŸÐ¾Ð¸ÑÐº Ñ€ÐµÑÑ‚Ð¾Ñ€Ð°Ð½Ð¾Ð² Ð¸Ð»Ð¸ ÐµÐ´Ñ‹...',
      'nav_home': 'Ð“Ð»Ð°Ð²Ð½Ð°Ñ',
      'nav_favorites': 'Ð˜Ð·Ð±Ñ€Ð°Ð½Ð½Ð¾Ðµ',
      'nav_cart': 'ÐšÐ¾Ñ€Ð·Ð¸Ð½Ð°',
      'nav_profile': 'ÐŸÑ€Ð¾Ñ„Ð¸Ð»ÑŒ',
      'products': 'ÐŸÑ€Ð¾Ð´ÑƒÐºÑ‚Ñ‹',
      'no_fav_res': 'Ð›ÑŽÐ±Ð¸Ð¼Ñ‹Ñ… Ñ€ÐµÑÑ‚Ð¾Ñ€Ð°Ð½Ð¾Ð² Ð½Ðµ Ð½Ð°Ð¹Ð´ÐµÐ½Ð¾!',
      'no_fav_prod': 'Ð›ÑŽÐ±Ð¸Ð¼Ñ‹Ñ… Ð¿Ñ€Ð¾Ð´ÑƒÐºÑ‚Ð¾Ð² Ð½Ðµ Ð½Ð°Ð¹Ð´ÐµÐ½Ð¾!',
      'nav_orders': 'Ð—Ð°ÐºÐ°Ð·Ñ‹',
      'orders': 'ÐœÐ¾Ð¸ Ð·Ð°ÐºÐ°Ð·Ñ‹',
      'addresses': 'ÐœÐ¾Ð¸ Ð°Ð´Ñ€ÐµÑÐ°',
      'payment_methods': 'Ð¡Ð¿Ð¾ÑÐ¾Ð±Ñ‹ Ð¾Ð¿Ð»Ð°Ñ‚Ñ‹',
      'coupons': 'ÐœÐ¾Ð¸ ÐºÑƒÐ¿Ð¾Ð½Ñ‹',
      'help_support': 'ÐŸÐ¾Ð¼Ð¾Ñ‰ÑŒ Ð¸ Ð¿Ð¾Ð´Ð´ÐµÑ€Ð¶ÐºÐ°',
      'mugut_support': 'ÐœÑƒÐ³Ñ‚ Ð¿Ð¾Ð´Ð´ÐµÑ€Ð¶ÐºÐ°',
      'logout': 'Ð’Ñ‹Ð¹Ñ‚Ð¸',
      'logout_confirm_title': 'Ð’Ñ‹Ñ…Ð¾Ð´',
      'logout_confirm_desc': 'Ð’Ñ‹ ÑƒÐ²ÐµÑ€ÐµÐ½Ñ‹, Ñ‡Ñ‚Ð¾ Ñ…Ð¾Ñ‚Ð¸Ñ‚Ðµ Ð²Ñ‹Ð¹Ñ‚Ð¸ Ð¸Ð· ÑÐ²Ð¾ÐµÐ³Ð¾ Ð°ÐºÐºÐ°ÑƒÐ½Ñ‚Ð°?',
      'clear_cart': 'ÐžÑ‡Ð¸ÑÑ‚Ð¸Ñ‚ÑŒ ÐºÐ¾Ñ€Ð·Ð¸Ð½Ñƒ',
      'clear_cart_confirm': 'Ð’Ñ‹ ÑƒÐ²ÐµÑ€ÐµÐ½Ñ‹, Ñ‡Ñ‚Ð¾ Ñ…Ð¾Ñ‚Ð¸Ñ‚Ðµ ÑƒÐ´Ð°Ð»Ð¸Ñ‚ÑŒ Ð²ÑÐµ Ñ‚Ð¾Ð²Ð°Ñ€Ñ‹ Ð¸Ð· ÐºÐ¾Ñ€Ð·Ð¸Ð½Ñ‹?',
      'cancel': 'ÐžÑ‚Ð¼ÐµÐ½Ð°',
      'clear': 'ÐžÑ‡Ð¸ÑÑ‚Ð¸Ñ‚ÑŒ',
      'empty_cart_msg': 'Ð’ Ð²Ð°ÑˆÐµÐ¹ ÐºÐ¾Ñ€Ð·Ð¸Ð½Ðµ Ð¿Ð¾ÐºÐ° Ð½ÐµÑ‚ Ñ‚Ð¾Ð²Ð°Ñ€Ð¾Ð²!',
      'empty_cart_desc': 'Ð’Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ Ð¾Ð´Ð½Ð¾ Ð¸Ð· Ð²ÐºÑƒÑÐ½Ñ‹Ñ… Ð±Ð»ÑŽÐ´ Ð¿Ñ€ÑÐ¼Ð¾ ÑÐµÐ¹Ñ‡Ð°Ñ\nand Ð½Ð°Ñ‡Ð½Ð¸Ñ‚Ðµ Ð½Ð°Ð¿Ð¾Ð»Ð½ÑÑ‚ÑŒ ÑÐ²Ð¾ÑŽ ÐºÐ¾Ñ€Ð·Ð¸Ð½Ñƒ.',
      'start_shopping': 'ÐÐ°Ñ‡Ð°Ñ‚ÑŒ Ð¿Ð¾ÐºÑƒÐ¿ÐºÐ¸',
      'subtotal': 'ÐŸÐ¾Ð´Ñ‹Ñ‚Ð¾Ð³',
      'delivery_fee': 'Ð¡Ñ‚Ð¾Ð¸Ð¼Ð¾ÑÑ‚ÑŒ Ð´Ð¾ÑÑ‚Ð°Ð²ÐºÐ¸',
      'service_fee': 'Ð¡ÐµÑ€Ð²Ð¸ÑÐ½Ñ‹Ð¹ ÑÐ±Ð¾Ñ€',
      'total_price': 'Ð˜Ñ‚Ð¾Ð³Ð¾Ð²Ð°Ñ ÑÑƒÐ¼Ð¼Ð°',
      'complete_order': 'ÐžÑ„Ð¾Ñ€Ð¼Ð¸Ñ‚ÑŒ Ð·Ð°ÐºÐ°Ð·',
      'register_title': 'Ð ÐµÐ³Ð¸ÑÑ‚Ñ€Ð°Ñ†Ð¸Ñ',
      'create_account': 'Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ Ð°ÐºÐºÐ°ÑƒÐ½Ñ‚',
      'register_desc': 'Ð—Ð°Ñ€ÐµÐ³Ð¸ÑÑ‚Ñ€Ð¸Ñ€ÑƒÐ¹Ñ‚ÐµÑÑŒ, Ð²Ð²ÐµÐ´Ñ ÑÐ²Ð¾Ðµ Ð¸Ð¼Ñ Ð¸ Ð½Ð¾Ð¼ÐµÑ€ Ñ‚ÐµÐ»ÐµÑ„Ð¾Ð½Ð°.',
      'full_name': 'Ð˜Ð¼Ñ Ð¸ Ð¤Ð°Ð¼Ð¸Ð»Ð¸Ñ',
      'already_have_account': 'Ð£Ð¶Ðµ ÐµÑÑ‚ÑŒ Ð°ÐºÐºÐ°ÑƒÐ½Ñ‚?',
      'fill_all_fields': 'ÐŸÐ¾Ð¶Ð°Ð»ÑƒÐ¹ÑÑ‚Ð°, Ð·Ð°Ð¿Ð¾Ð»Ð½Ð¸Ñ‚Ðµ Ð²ÑÐµ Ð¿Ð¾Ð»Ñ',
      'register_success': 'Ð ÐµÐ³Ð¸ÑÑ‚Ñ€Ð°Ñ†Ð¸Ñ Ð¿Ñ€Ð¾ÑˆÐ»Ð° ÑƒÑÐ¿ÐµÑˆÐ½Ð¾!',
      'register_failed': 'ÐžÑˆÐ¸Ð±ÐºÐ° Ñ€ÐµÐ³Ð¸ÑÑ‚Ñ€Ð°Ñ†Ð¸Ð¸',
      'phone_already_registered': 'Ð­Ñ‚Ð¾Ñ‚ Ð½Ð¾Ð¼ÐµÑ€ ÑƒÐ¶Ðµ Ð·Ð°Ñ€ÐµÐ³Ð¸ÑÑ‚Ñ€Ð¸Ñ€Ð¾Ð²Ð°Ð½. ÐŸÐ¾Ð¶Ð°Ð»ÑƒÐ¹ÑÑ‚Ð°, Ð²Ð¾Ð¹Ð´Ð¸Ñ‚Ðµ.',
      'phone_not_registered': 'Ð­Ñ‚Ð¾Ñ‚ Ð½Ð¾Ð¼ÐµÑ€ Ð½Ðµ Ð·Ð°Ñ€ÐµÐ³Ð¸ÑÑ‚Ñ€Ð¸Ñ€Ð¾Ð²Ð°Ð½. ÐŸÐ¾Ð¶Ð°Ð»ÑƒÐ¹ÑÑ‚Ð°, ÑÐ½Ð°Ñ‡Ð°Ð»Ð° Ð·Ð°Ñ€ÐµÐ³Ð¸ÑÑ‚Ñ€Ð¸Ñ€ÑƒÐ¹Ñ‚ÐµÑÑŒ.',
      'error': 'ÐžÑˆÐ¸Ð±ÐºÐ°',
    },
  };

  String translate(String key) {
    return translations[_selectedLang]?[key] ?? key;
  }
}

