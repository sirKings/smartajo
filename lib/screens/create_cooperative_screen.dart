import 'dart:math';

import 'package:app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/constants.dart';

class CreateCoopScreen extends StatefulWidget {

  static String id = "createCoopScreen";

  @override
  _CreateCoopState createState() => _CreateCoopState();


}

var _loading = false;

class _CreateCoopState extends State<CreateCoopScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, ChatScreen.id);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Create Cooperative"),
          ),
          body: MyCustomForm(),

      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  var _store = Firestore.instance;
  var _auth = FirebaseAuth.instance;
  var name = "";
  var amount = "";
  var number = "";

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        key: _scaffoldKey,
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a name for your Cooperative';
                    }
                    return null;
                  },
                    decoration: InputDecoration(
                      hintText: 'Enter Cooperative name',
                    ),
                ),

                TextFormField(

                  onChanged: (value) {
                    amount = value;
                  },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter Amount per contributor';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Amount per Contributor',
                    ),
                    keyboardType: TextInputType.number,
                ),

                TextFormField(

                  onChanged: (value) {
                    number = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter number of contributors';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter number of contributors',
                  ),
                  keyboardType: TextInputType.number,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Color(0xFF1E0763),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () {
                        //Implement registration functionality.
                        if(_formKey.currentState.validate()){
                          setState(() {
                            _loading = true;
                          });
                          createCoops();
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Create Cooperative',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future createCoops() async {

    print("Creating Coops");

    var time = DateTime.now().millisecondsSinceEpoch;
    var code = _getCode(time).toUpperCase();
    var message = "";

    try{
      DocumentReference ref = await _store.collection(Database.COOPERATIVES).add({
        "name": name,
        "number": number,
        "creatorName": localUser.name,
        "amount": amount,
        "creator": myUser.uid,
        "createdAt": time,
        "code": code
      });


      await _store.collection(Database.COOPERATIVES).document(ref.documentID).updateData({
        "id": ref.documentID
      });

      await _store.collection(Database.USERS).document(myUser.uid).collection(Database.COOPERATIVES).add({
        "name": name,
        "number": number,
        "amount": amount,
        "creator": myUser.uid,
        "creatorName": localUser.name,
        "createdAt": time,
        "id": ref.documentID,
        "code": code
      });

      await _store.collection(Database.MEMBERS).add({
        Database.COOPSID: ref.documentID,
        'name': localUser.name,
        'phone': localUser.phone,
        'email': localUser.email,
        'id': localUser.id,
        'position': 0
      });

      _formKey.currentState.reset();
      message = 'Cooperative created successfully';
    }catch(e){
      message = 'Could not create cooperative, Try again later';
    }

    setState(() {
      _loading = false;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  String _getCode(int time){
    var chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = Random(time);
    String result = "";
    for (var i = 0; i < 8; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

}