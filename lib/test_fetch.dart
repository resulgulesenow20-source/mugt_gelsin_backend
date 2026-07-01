import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mugut_gelsin/firebase_options.dart';
import 'package:mugut_gelsin/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final apiService = ApiService();
  try {
    final campaigns = await apiService.fetchCampaigns();
    print("SUCCESS: Fetched ${campaigns.length} campaigns");
    for (var c in campaigns) {
      print("- ${c.title} (Shop: ${c.shopId}, Img: ${c.imageUrl})");
    }
  } catch (e) {
    print("ERROR: $e");
  }
  
  // Exit script
  import('dart:io').then((io) => io.exit(0));
}
