import 'dart:math';

import 'package:app/screens/chat_screen.dart';
import 'package:app/screens/coop_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/constants.dart';
import 'package:app/Models.dart';



class CollectionDetailsScreen extends StatefulWidget {

  static String id = "joinCoopScreen";

  @override
  _CollectionDetailsState createState() => _CollectionDetailsState();


}

var _loading = false;

class _CollectionDetailsState extends State<CollectionDetailsScreen> {

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    //Navigator.pushReplacementNamed(context, ChatScreen.id);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Join Cooperative"),
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
          padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
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
                      return 'Please enter cooperative code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Cooperative code',
                  ),
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
                          joinCoops();
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Join Cooperative',
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

  Future joinCoops() async {

    print("Joining Coops");

    var time = DateTime.now().millisecondsSinceEpoch;
    var message = "";

    try{

      QuerySnapshot myCoop = await _store.collection(Database.USERS)
          .document(localUser.id)
          .collection(Database.COOPERATIVES)
          .where(Database.CODE, isEqualTo: name.toUpperCase())
          .getDocuments();

      if(myCoop.documents.isNotEmpty){
        message = "You are already a member of this Cooperative";
      }else{
        QuerySnapshot coop = await _store.collection(Database.COOPERATIVES).where(Database.CODE, isEqualTo: name.toUpperCase()).getDocuments();

        if(coop.documents.isEmpty){
          message = "Cooperative does not exist, Please check the code";
        }else{

          Coop coope = Coop(coop.documents[0].data);
          CoopDetailsPageArgument arg = CoopDetailsPageArgument();
          arg.coop = coope;
          arg.isJoining = true;


          Navigator.pushReplacementNamed(context, CoopDetailsScreen.id, arguments: arg);
          return;
          //message = "Cooperative found ${Coop(coop.documents[0].data).name}";
          //_formKey.currentState.reset();
        }
      }

    }catch(e){

      message = 'Could not find cooperative, Try again later';
    }

    setState(() {
      _loading = false;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

}