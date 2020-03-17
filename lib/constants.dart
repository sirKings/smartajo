import 'package:app/Models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

FirebaseUser myUser;
LocalUser localUser;

class MyAppClient {

    Future<FirebaseUser> getCurrentUser() async {
      FirebaseUser _user = await FirebaseAuth.instance.currentUser();
      try{
        if(_user.uid == null){
          print("no user");
          return null;
        }else{
          print("${_user.uid}");

          _getUserFromDb(_user.uid);

          myUser = _user;
          return _user;
        }
      }catch(e){
        return null;
      }
    }

    Future<LocalUser> _getUserFromDb(String uid) async {

      var userData = (await Firestore.instance.collection(Database.USERS).document(uid).get());

      print("User datea");
      print(userData.data);

      localUser = LocalUser(userData.data);

    }

}

class Database {
  static String COOPERATIVES = "cooperatives";
  static String USERS = "users";
  static String PAYMENTS = "payments";
  static String CARDS = "cards";
  static String CODE = "code";
  static String MEMBERS = "members";
  static String COOPSID = "coopId";
  static String COLLECTION = "collections";
}

class Constants {
  static String FIRST_TIMER = "firstTimer";
  static String D = "Daily";
  static String W = "Weekly";
  static String M = "Monthly";
}

class Colours {
  static Color primary = Color(0xFF1E0763);
  static Color ash = Color(0xFFE3DADA);
  static Color touquise = Color(0xFF14B8B3);
}