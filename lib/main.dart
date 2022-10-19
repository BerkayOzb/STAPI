// ignore_for_file: avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore/firebase_options.dart';
import 'package:flutter_firestore/firestore_ismleri.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirestoreIslemleri(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({Key? key}) : super(key: key);

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  late FirebaseAuth auth;
  final String _email = 'eser.karaceper@cubedots.com';
  final String _password = 'passwordYeni';
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User Oturumu kapalı');
      } else {
        print(
            'User oturumu açık ${user.email} ve email durumu ${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Firebase Dersleri'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  createUserEmailAndPassword();
                },
                child: const Text('Email/Sifre Kayit')),
            ElevatedButton(
                onPressed: () {
                  LoginUserEmailAndPassword();
                },
                child: const Text('Email/Sifre Giris')),
            ElevatedButton(
                onPressed: () {
                  SignOutUser();
                },
                child: const Text('Oturumu Kapat')),
            ElevatedButton(
                onPressed: () {
                  DeleteUser();
                },
                child: const Text('Kullanıcıyı Sil')),
            ElevatedButton(
                onPressed: () {
                  BilgileriGoster();
                },
                child: const Text('Bilgileri Göster.')),
            ElevatedButton(
                onPressed: () {
                  ChangeEmail();
                },
                child: const Text('Email Değiştir.')),
            ElevatedButton(
                onPressed: () {
                  SignInWithGMail();
                },
                child: const Text('Gmail ile Giriş.')),
            ElevatedButton(
                onPressed: () {
                  LoginWithPhoneNumber();
                },
                child: const Text('Telefon No ile Giriş.')),
          ],
        ),
      ),
    );
  }

  void LoginWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+905527503316',
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint(credential.toString());
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        String _smsCode = "123456";

        var _credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _smsCode);
        await auth.signInWithCredential(_credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void createUserEmailAndPassword() async {
    try {
      var userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      var _myUser = userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        print('Kullanıcının maili onaylanmış.');
      }
      print(userCredential.toString());
    } catch (exception) {
      print(exception.toString());
    }
  }

  void LoginUserEmailAndPassword() async {
    try {
      var userCredential = await auth.signInWithEmailAndPassword(
          email: _email, password: _password);

      print(userCredential.toString());
    } catch (exception) {
      print(exception.toString());
    }
  }

  void SignOutUser() async {
    var _user = GoogleSignIn().currentUser;
    if (_user == null) {
      await auth.signOut();
    } else {
      await GoogleSignIn().disconnect();
    }
  }

  void DeleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      print('Kullanıcı oturum açmadığı için silinemez');
    }
  }

  void ChangePassword() async {
    try {
      await auth.currentUser!.updatePassword('password');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('reauthenticate olunacak');
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword('password');
        await auth.signOut();
        print('Şifre güncellendi');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void ChangeEmail() async {
    try {
      await auth.currentUser!.updateEmail('berkayozbuga@gmail.com');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('reauthenticate olunacak');
        var credential =
            EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updateEmail('berkayozbuga@gmail.com');
        await auth.signOut();
        print('Şifre güncellendi');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void SignInWithGMail() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void BilgileriGoster() async {
    var _user = GoogleSignIn().currentUser;
    if (_user != null) {
      debugPrint(auth.currentUser!.email);
    } else {
      print('Kullanıcı Oturum Açmadı');
    }
  }
}
