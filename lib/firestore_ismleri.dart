// ignore_for_file: must_be_immutable, avoid_print, no_leading_underscores_for_local_identifiers, unused_local_variable
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreIslemleri extends StatefulWidget {
  const FirestoreIslemleri({Key? key}) : super(key: key);

  @override
  State<FirestoreIslemleri> createState() => _FirestoreIslemleriState();
}

class _FirestoreIslemleriState extends State<FirestoreIslemleri> {
  late FirebaseFirestore _firestore;
  FirebaseFirestore firestoree = FirebaseFirestore.instance;
  StreamSubscription? _userSubscribe;
  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    //IDLer
    debugPrint(_firestore.collection('users').id);
    debugPrint(_firestore.collection('users').doc().id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore NoSQL'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  veriEkleAdd();
                  print('basmaa');
                },
                child: const Text('Veri Ekle Add')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                onPressed: () {
                  veriEkleSet();
                },
                child: const Text('Veri Ekle Set')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                onPressed: () {
                  veriGuncelle();
                },
                child: const Text('Veri Güncelle')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.orange),
                onPressed: () {
                  veriSil();
                },
                child: const Text('Veri Sil')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.pink),
                onPressed: () {
                  veriOkuOneTime();
                },
                child: const Text('Veri OkuOneTime')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.purple),
                onPressed: () {
                  veriOkuRealTime();
                },
                child: const Text('Veri OkuRealTime')),
            ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.teal),
                onPressed: () {
                  streamDurdur();
                },
                child: const Text('Stream Durdur')),
            ElevatedButton(
                onPressed: () {
                  batchKavrami();
                },
                child: const Text('Batch')),
            ElevatedButton(
                onPressed: () {
                  transactionKavrami();
                },
                child: const Text('Transaction')),
            ElevatedButton(
                onPressed: () {
                  queryingData();
                },
                child: const Text('Veri Sorgulama')),
            ElevatedButton(
                onPressed: () {
                  kameraGaleriImageUpload();
                },
                child: const Text('Kamera Galeri Image Upload')),
          ],
        ),
      ),
    );
  }

  veriEkleAdd() async {
    Map<String, dynamic> _eklenecekUser = {};
    _eklenecekUser['isim'] = 'berkay';
    _eklenecekUser['yas'] = 24;
    _eklenecekUser['ogrenciMi'] = false;
    _eklenecekUser['adres'] = {'il': 'istanbul', 'ilce': 'eyup'};
    _eklenecekUser['renkler'] = FieldValue.arrayUnion(['siyah', 'beyaz']);
    _eklenecekUser['createdDate'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').add(_eklenecekUser);
  }

  veriEkleSet() async {
    var _yeniDocID = _firestore.collection('users').doc().id;
    await _firestore
        .doc('users/$_yeniDocID')
        .set({'isim': 'damla', 'userID': _yeniDocID});
    // await _firestore.doc('users/224WDhEN0aCjkr6HX59q').set({'okul': 'ALKÜ'},
    //     SetOptions(merge: true)); // olan veriyi silmez üstüne bu veriyi ekler.

    await _firestore.doc('users/224WDhEN0aCjkr6HX59q').set({
      'okul': 'ALKÜ',
      'yas': FieldValue.increment(1)
    }); //  Olan Veriyi siler direkt bunu yazar
  }

  veriGuncelle() async {
    await _firestore
        .doc('users/E1Pcy6SYmcKJ71wKM9tx')
        .update({'adres.ilce': 'eyüpYeni'});
  }

  veriSil() async {
    await _firestore.doc('users/62imt1S4vZmB0Atn5bgA').delete();
    await _firestore
        .doc('users/hdoxYGfpkwVIgI2uV4cD')
        .update({'isim': FieldValue.delete()});
  }

  void veriOkuOneTime() async {
    var _usersDocuments = await _firestore.collection('users').get();
    debugPrint(_usersDocuments.size.toString());
    debugPrint(_usersDocuments.docs.length.toString());
    for (var element in _usersDocuments.docs) {
      debugPrint("Döküman ID ${element.id}");
      Map userMap = element.data();
      debugPrint(userMap['isim']);
    }

    var _berkayDoc = await _firestore.doc('users/ypkeXEvaIPeqai3XAx0I').get();
    debugPrint(_berkayDoc.data()!['adres']['il'].toString());
  }

  void veriOkuRealTime() async {
    //var _userStream = _firestore.collection('users').snapshots();
    var _userStream = _firestore.doc('users/ypkeXEvaIPeqai3XAx0I').snapshots();
    _userSubscribe = _userStream.listen((event) {
      debugPrint(event.data().toString());
      // event.docChanges.forEach((element) {
      //   debugPrint(element.doc.data().toString());
      // });
      // event.docs.forEach((element) {
      //   debugPrint(element.data().toString());
      // });
    });
  }

  void streamDurdur() async {
    await _userSubscribe?.cancel();
  }

  batchKavrami() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection('counter');
    /* for (int i = 0; i < 100; i++) {
       var _yeniDoc = _counterColRef.doc();
      _batch.set(_yeniDoc, {'sayac': ++i, 'id': _yeniDoc.id});
    }
    */
    /*var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(
          element.reference, {'createdAt': FieldValue.serverTimestamp()});
    });
    */
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(element.reference);
    });
    await _batch.commit();
  }

  transactionKavrami() async {
    _firestore.runTransaction((transaction) async {
      //berkayin bakiye ogren
      //100 lira düs
      //damlaya 100 lira ekle
      DocumentReference<Map<String, dynamic>> berkayRef =
          _firestore.doc('users/IGvyChuDUikPOplKGZse');
      DocumentReference<Map<String, dynamic>> damlaRef =
          _firestore.doc('users/JNQEK3FYBE9jsU8Mqeq8');

      var _berkaySnapshot = (await transaction.get(berkayRef));
      var _berkayBakiye = _berkaySnapshot.data()!['para'];
      if (_berkayBakiye > 100) {
        var _yeniBakiye = _berkayBakiye - 100;
        transaction.update(berkayRef, {'para': _yeniBakiye});
        transaction.update(damlaRef, {'para': FieldValue.increment(100)});
      }
    });
  }

  queryingData() async {
    var _userRef = _firestore.collection('users').limit(3);
    //var _sonuc = await _userRef.where('yas', isNotEqualTo: 24).get();
    //var _sonuc = await _userRef.where('yas', whereIn: [24, 34]).get();
    var _sonuc =
        await _userRef.where('renkler', arrayContains: ['siyah']).get();
    for (var user in _sonuc.docs) {
      debugPrint(user.data().toString());
    }
    var _sirala = await _userRef.orderBy('yas', descending: true).get();
    for (var user in _sirala.docs) {
      debugPrint(user.data().toString());
    }
    var _stringSearch = await _userRef
        .orderBy('email')
        .startAt(['berkay']).endAt(['berkay' + '\uf8ff']).get();
    for (var user in _stringSearch.docs) {
      debugPrint(user.data().toString());
    }
  }

  kameraGaleriImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    XFile? _file = await _picker.pickImage(source: ImageSource.camera);
    var _preofileRef = FirebaseStorage.instance.ref('users/profil_resimleri');
    var _task = _preofileRef.putFile(File(_file!.path));
    _task.whenComplete(() async {
      var _url = await _preofileRef.getDownloadURL();
      _firestore
          .doc('users/JNQEK3FYBE9jsU8Mqeq8')
          .set({'profile_pic': _url.toString()}, SetOptions(merge: true));
      debugPrint(_url);
    });
  }
}
