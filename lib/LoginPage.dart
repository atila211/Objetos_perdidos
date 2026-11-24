import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  String msgError = '';
  bool cargando = false;

  Future<void> loginGoogle() async {
    setState(() => cargando = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => cargando = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        msgError = 'Error al iniciar sesión';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003087),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 90, color: Colors.white),
              SizedBox(height: 10),
              Text(
                'Objetos Perdidos',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Campus USM',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 60),
              if (cargando)
                CircularProgressIndicator(color: Colors.white)
              else
                ElevatedButton.icon(
                  onPressed: loginGoogle,
                  icon: Icon(Icons.login),
                  label: Text('Iniciar sesión con Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF003087),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              SizedBox(height: 20),
              Text(msgError, style: TextStyle(color: Colors.red.shade200)),
            ],
          ),
        ),
      ),
    );
  }
}
