
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/Models.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  static String id = "payment";

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  var _auth = FirebaseAuth.instance;
  var _store = Firestore.instance;
  List<DocumentSnapshot> listP;
  List<CardP> _cards = List<CardP>();
  var _loading = true;

  var publicKey = "pk_test_cc549a49b32b8a93ceab29d5c0cbfbe181bdd7e4";
  var secretKey = "sk_test_29cd1555470991605a58ea724c6648e15d68e528";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    PaystackPlugin.initialize(
        publicKey: publicKey);
    getUserCards();
  }

  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      length: 1,
      child: LoadingOverlay(
        isLoading: _loading,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "My Payment Methods",
                ),
              ],
            ),
            title: Text('Payment'),
          ),
          body: TabBarView(
            children: [
              Stack(
                children: <Widget>[
                  _cards.isEmpty
                      ? Container(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Text(
                      "You don't have any payment method yet",
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var coop = _cards[index];

                      return ListTile(
                        title: Text("************${coop.number}"),
                        subtitle: Text('Created by ${coop.creatorName}'),
                        onTap: () => onCoopTapped(coop),
                      );
                    },
                    itemCount: _cards.length,
                  ),
                  Positioned(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                    child: MaterialButton(
                        elevation: 5,
                        color: Color(0xFF1E0763),
                        child: Text(
                          "Add Card",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          _chargeAlert();
                        }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Function onCoopTapped(CardP coop) {

  }

  Future<void> addcard() async {
    Charge charge = Charge()
      ..amount = 100
      ..reference = _getReference()
      ..email = localUser.email;
    CheckoutResponse response = await PaystackPlugin.checkout(context, charge: charge, method: CheckoutMethod.card);

    if(response.status){
      saveCardDetails(response);
      setState(() {
        _loading = true;
      });
    }
  }

  String _getReference() {
    return 'ChargedFrom_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> saveCardDetails(CheckoutResponse res) async{
    print("Creating Coops");

    String chargeCode = await verifyCard(res.reference);

    if(chargeCode != null){
      var time = DateTime.now().millisecondsSinceEpoch;

      DocumentReference ref = await _store.collection(Database.CARDS).add({
        "chargeCode": chargeCode,
        "number": res.card.last4Digits,
        "creatorName": localUser.name,
        "creator": myUser.uid,
        "createdAt": time,
      });

      await _store.collection(Database.CARDS).document(ref.documentID).updateData({
        "id": ref.documentID
      });

      await _store.collection(Database.USERS).document(myUser.uid).collection(Database.CARDS).add({
        "chargeCode": chargeCode,
        "number": res.card.last4Digits,
        "creatorName": localUser.name,
        "creator": myUser.uid,
        "createdAt": time,
        "id": ref.documentID
      });

      localUser.chargeCode = chargeCode;

      _store.collection(Database.USERS).document(localUser.id).updateData({
        'chargeCode': chargeCode
      });

    }else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Could not get Authorization code, Please use another card")));
    }

    getUserCards();
  }


  Future<String> verifyCard(String ref) async {
    final http.Response response = await http.get('https://api.paystack.co/transaction/verify/$ref',
        headers: {
          "Authorization": "Bearer $secretKey"
    });
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String chargeCode;

      String status = json.decode(response.body)["data"]["status"];

      print(json.decode(response.body));

      if(status == "success"){
        chargeCode = json.decode(response.body)["data"]["authorization"]["authorization_code"];
        return chargeCode;
      }else{
        return null;
      }

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<List<Widget>> getUserCards() async {

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(Database.USERS)
        .document(myUser.uid)
        .collection(Database.CARDS)
        .getDocuments();

    listP = querySnapshot.documents;

    print(listP);

    setState(() {
      _loading = false;
      _cards = listP.map((doc) => CardP(doc.data)).toList();
    });
  }

    Future<void> _chargeAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Information'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Your card will be charged NGN100 which will be refunded later, Do you agree?'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  addcard();
                },
              ),
            ],
          );
        },
      );
    }



}