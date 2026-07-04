import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://axbgpbaegsgynswysbuf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4YmdwYmFlZ3NneW5zd3lzYnVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxODU3NTEsImV4cCI6MjA5ODc2MTc1MX0.Henu1zn1q1LqMIdggwKlw82m63b5NLLKjEXQ2aCvfJg',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harcama Takip',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        fontFamily: 'Roboto',
      ),
      home: const HarcamaSayfasi(),
    );
  }
}

class HarcamaSayfasi extends StatefulWidget {
  const HarcamaSayfasi({super.key});

  @override
  State<HarcamaSayfasi> createState() => _HarcamaSayfasiState();
}

class _HarcamaSayfasiState extends State<HarcamaSayfasi> {
  List<Map<String, dynamic>> harcamalar = [];
  @override
void initState() {
  super.initState();
  verileriYukle();
}

  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController tutarController = TextEditingController();

  static const Color anaRenk = Color.fromARGB(255, 233, 144, 10);
  static const Color koyuYazi = Color(0xFF1A1A2E);
  static const Color kirmizi = Color(0xFFE53E3E);

 Future<void> harcamaEkle() async {
  if (kategoriController.text.isEmpty || tutarController.text.isEmpty) {
    return;
  }

  final yeniHarcama = {
    "kategori": kategoriController.text,
    "tutar": double.parse(tutarController.text),
  };

  try {
    final response = await supabase.from('harcamalar').insert(yeniHarcama).select();

    setState(() {
      harcamalar.add(response[0]);
      kategoriController.clear();
      tutarController.clear();
    });
  } catch (e) {
    print("HATA OLUŞTU: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hata: $e")),
    );
  }
}
Future<void> verileriYukle() async {
  final response = await supabase.from('harcamalar').select();
  setState(() {
    harcamalar = List<Map<String, dynamic>>.from(response);
  });
}
  Future<void> harcamaSil(int index) async {
  final id = harcamalar[index]['id'];
  await supabase.from('harcamalar').delete().eq('id', id);
  setState(() {
    harcamalar.removeAt(index);
  });
}
  IconData kategoriIkonu(String kategori) {
    switch (kategori.toLowerCase()) {
      case "market":
        return Icons.shopping_cart_rounded;
      case "ulaşım":
        return Icons.directions_bus_rounded;
      case "eğlence":
        return Icons.movie_rounded;
      case "okul":
        return Icons.school_rounded;
      case "ev":
        return Icons.home_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    double toplam = 0;
    for (var harcama in harcamalar) {
      toplam += harcama["tutar"];
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 27, 51, 148),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harcama Takip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "TOPLAM HARCAMA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "₺${toplam.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${harcamalar.length} harcama kaydı",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                TextField(
                  controller: kategoriController,
                  style: const TextStyle(fontSize: 15, color: koyuYazi),
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.category_rounded, color: Color.fromARGB(255, 7, 0, 58)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 25, 179, 225), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tutarController,
                  style: const TextStyle(fontSize: 15, color: koyuYazi),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Tutar (TL)',
                    labelStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.payments_rounded, color:  Color.fromARGB(255, 7, 0, 58)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 10, 75, 140), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: harcamaEkle,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Harcama Ekle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 8, 81, 105),
                      elevation: 3,
                      shadowColor: anaRenk.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Text(
                  "Harcamalar",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: koyuYazi,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: harcamalar.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.receipt_long_rounded, size: 56, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "Henüz harcama eklenmedi",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: harcamalar.length,
                    itemBuilder: (context, index) {
                      final harcama = harcamalar[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEAEAEA)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F7EF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(kategoriIkonu(harcama["kategori"]), color: const Color.fromARGB(255, 30, 170, 65)),
                          ),
                          title: Text(
                            harcama["kategori"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: koyuYazi,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₺${harcama["tutar"].toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: kirmizi),
                                onPressed: () => harcamaSil(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}