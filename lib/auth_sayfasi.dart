import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSayfasi extends StatefulWidget {
  const AuthSayfasi({super.key});

  @override
  State<AuthSayfasi> createState() => _AuthSayfasiState();
}

class _AuthSayfasiState extends State<AuthSayfasi> {
  final emailController = TextEditingController();
  final sifreController = TextEditingController();

  bool girisModuAktif = true; // true: giriş ekranı, false: kayıt ekranı
  bool yukleniyor = false;
  String? hataMesaji;

  Future<void> girisYap() async {
    setState(() {
      yukleniyor = true;
      hataMesaji = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: sifreController.text.trim(),
      );
      // Başarılıysa main.dart'taki StreamBuilder otomatik yönlendirecek
    } on AuthException catch (e) {
      setState(() {
        hataMesaji = e.message;
      });
    } catch (e) {
      setState(() {
        hataMesaji = "Bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  Future<void> kayitOl() async {
    setState(() {
      yukleniyor = true;
      hataMesaji = null;
    });
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: sifreController.text.trim(),
      );
      setState(() {
        hataMesaji = "Kayıt başarılı! Şimdi giriş yapabilirsin.";
        girisModuAktif = true;
      });
    } on AuthException catch (e) {
      setState(() {
        hataMesaji = e.message;
      });
    } catch (e) {
      setState(() {
        hataMesaji = "Bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  size: 64, color: Color(0xFF00A86B)),
              const SizedBox(height: 16),
              Text(
                girisModuAktif ? "Giriş Yap" : "Kayıt Ol",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sifreController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              if (hataMesaji != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    hataMesaji!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: yukleniyor
                      ? null
                      : (girisModuAktif ? girisYap : kayitOl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                  ),
                  child: yukleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(girisModuAktif ? "Giriş Yap" : "Kayıt Ol"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    girisModuAktif = !girisModuAktif;
                    hataMesaji = null;
                  });
                },
                child: Text(
                  girisModuAktif
                      ? "Hesabın yok mu? Kayıt ol"
                      : "Zaten hesabın var mı? Giriş yap",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}