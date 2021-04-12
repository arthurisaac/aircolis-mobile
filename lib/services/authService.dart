import 'package:aircolis/pages/auth/login.dart';
import 'package:aircolis/pages/home/home.dart';
import 'package:aircolis/pages/user/register.dart';
import 'package:aircolis/utils/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong/latlong.dart';

class AuthService {
  final user = FirebaseAuth.instance.currentUser;

  handleAuth() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context).translate("anErrorHasOccurred"));
        }

        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  isUserLogged() {
    User _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      String uid = _user.uid;
      CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
      userCollection.doc(uid).get().then((doc) {
        if (doc.exists) {
          return HomeScreen();
        } else {
          return RegisterScreen(phoneNumber: '');
        }
      });
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }

  void updatePosition(LatLng position) {
    User _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      var uid = _user.uid;
      var snapshot = FirebaseFirestore.instance.collection('users').doc(uid);

      Map<String, dynamic> _position = {
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
      Map<String, dynamic> data = {
        "position": _position,
      };
      snapshot.update(data).then((value) {
        //print('position update');
      }).catchError((onError) {
        print('error position saved');
      });

    } else {
      print('User is null');
    }
  }

  void updateToken(String token) {
    User _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      var uid = _user.uid;
      var snapshot = FirebaseFirestore.instance.collection('users').doc(uid);

      Map<String, dynamic> data = {
        "token": token,
      };
      snapshot.update(data).then((value) {
        //print('position update');
      }).catchError((onError) {
        print('error position saved');
      });

    } else {
      print('User is null');
    }
  }

  Future<DocumentSnapshot> getUserDoc() {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

  Future<DocumentSnapshot> getSpecificUserDoc(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInEmailAndPassword(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<DocumentSnapshot> checkAccountExist() {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    return userCollection.doc(user.uid).get();
  }

  Future<QuerySnapshot> checkPhoneExistInDB(String phoneNumber) {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    return userCollection.where('phone', isEqualTo: phoneNumber).get();
  }

  Future<void> saveUser() async {
    final User user = FirebaseAuth.instance.currentUser;
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    DocumentReference documentReferencer = userCollection.doc(user.uid);

    final Map<String, dynamic> data = {
      'uid' : user.uid,
      'firstname': user.displayName,
      'lastname': "",
      'presence': true,
      'isVerified': false,
      'email': user.email,
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
      'token': "",
      'photo': user.photoURL,
    };

    return await documentReferencer.set(data);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> saveNewUser(String firstname, String lastname, String phoneNumber) async {
    final User user = FirebaseAuth.instance.currentUser;
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    DocumentReference documentReferencer = userCollection.doc(user.uid);

    final Map<String, dynamic> data = {
      'uid' : user.uid,
      'firstname': firstname,
      'lastname': lastname,
      'presence': true,
      'isVerified': false,
      'email': user.email,
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
      'token': "",
      'photo': user.photoURL,
      'phone': phoneNumber
    };
    user.sendEmailVerification();

    return await documentReferencer.set(data);
  }

  Future<void> updateLastSignIn() async {
    final User user = FirebaseAuth.instance.currentUser;
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    DocumentReference documentReferencer = userCollection.doc(user.uid);

    final Map<String, dynamic> data = {
      'creationTime': user.metadata.creationTime,
      'lastSignInTime': user.metadata.lastSignInTime,
    };

    return await documentReferencer.update(data);
  }

  Future signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
  
}