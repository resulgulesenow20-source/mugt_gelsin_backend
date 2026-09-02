import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B0F6B),
        elevation: 0,
        title: Text(
          "Ulanyjy şertnamasy",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MUGT GELSIN – ULANYJY ŞERTNAMASY",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: const Color(0xFF130A2A),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("1. Şertnamanyň Taraplary we Maksady"),
              _buildSectionText(
                "Bu şertnama, \"Mugt Gelsin\" mobil programmasyny (mundan beýläk \"Platforma\" diýlip atlandyrylar) ulanýan müşderi (mundan beýläk \"Ulanyjy\" diýlip atlandyrylar) bilen Platformany dolandyrýan kompaniýanyň arasynda baglaşyldy. Şertnamanyň maksady, Ulanyjynyň Platforma arkaly garaşsyz restoranlardan sargyt etmeginiň düzgünlerini kesgitlemekdir."
              ),
              _buildSectionTitle("2. Platformanyň Wezipesi"),
              _buildSectionText(
                "Mugt Gelsin, diňe restoranlar bilen müşderileri birleşdirýän sanly aralykçy platformadyr. Mugt Gelsin iýmit taýýarlaýjy, restoran ýa-da kuryer (dostawka) kompaniýasy däldir. Platforma diňe Ulanyjynyň sargydyny restorana tehnologik taýdan ýetirmek hyzmatyny amala aşyrýar."
              ),
              _buildSectionTitle("3. Jogapkärçiligiň Çäklendirilişi"),
              _buildSectionText(
                "Platformanyň üsti bilen edilen sargytlarda;\n"
                "a) Naharyň hili, düzümi, gigiýenasy, saglyga zyýansyzlygy we dogry taýýarlanmagy,\n"
                "b) Sargydyň müşderä wagtynda, howpsuz we doly ýagdaýda eltip berilmegi (dostawka) doly we diňe sargydy taýýarlan restoranyň jogapkärçiligindedir.\n\n"
                "Mugt Gelsin kuryer hyzmatyny amala aşyrmaýandygy sebäpli, naharyň eltip berilmeginde ýüze çykyp biljek gijä galmalar, ýitgiler, sowamak ýa-da islendik zyýan üçin kanuny we maddy taýdan göni jogapkärçilik çekmeýär."
              ),
              _buildSectionTitle("4. Tölegler we Yzyna Gaýtarma"),
              _buildSectionText(
                "Ulanyjy sargyt edende tölegleri nagt ýa-da onlaýn usulda amala aşyryp biler. Taýýarlanyp başlanan sargytlary ýatyrmak (otmen etmek) ýa-da yzyna gaýtarmak (wozwrat) diňe restoranyň tassyklamagy bilen mümkindir. Mugt Gelsin, restoran tarapyndan kabul edilmedik yzyna gaýtarmalar üçin kepillik bermeýär."
              ),
              _buildSectionTitle("5. Şertnamany Üýtgetmek Hukugy"),
              _buildSectionText(
                "Mugt Gelsin kompaniýasy, geljekde öz kuryer ulgamyny ýa-da öz dükanlaryny (marketlerini) işe girizen ýagdaýynda ýa-da beýleki täze hyzmatlar goşulanda, öňünden habar bermezden bu şertnamanyň maddalaryny tek taraplaýyn üýtgetmek, täzelemek we goşmaçalar girizmek hukugyny özünde saklaýar. Üýtgedilen şertnama, Platformada yglan edilen pursadyndan güýje girýär. Ulanyjy, programmany ulanmagy dowam etdirmek bilen täze şertleri kabul eden hasaplanýar."
              ),
              _buildSectionTitle("6. Dawa-jenjelleri Çözmek"),
              _buildSectionText(
                "Bu şertnamadan gelip çykyp biljek islendik düşünişmezliklerde Türkmenistanyň kanunçylygy we kazyýetleri esas alynýar.\n\n"
                "Ulanyjy, \"Mugt Gelsin\" programmasynda hasap açyp we sargyt edip, bu şertnamanyň ähli maddalaryny okandygyny, düşünendigini we doly kabul edendigini tassyklaýar."
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF2B0F6B),
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.grey.shade700,
        height: 1.5,
      ),
    );
  }
}
