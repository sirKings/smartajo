import 'package:app/screens/create_cooperative_screen.dart';
import 'package:app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/Models.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

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

    var time = DateTime.now().millisecondsSinceEpoch;

    DocumentReference ref = await _store.collection(Database.CARDS).add({
      "chargeCode": res.reference,
      "number": res.card.last4Digits,
      "creatorName": localUser.name,
      "creator": myUser.uid,
      "createdAt": time,
    });

    await _store.collection(Database.CARDS).document(ref.documentID).updateData({
      "id": ref.documentID
    });

    await _store.collection(Database.USERS).document(myUser.uid).collection(Database.CARDS).add({
      "chargeCode": res.reference,
      "number": res.card.last4Digits,
      "creatorName": localUser.name,
      "creator": myUser.uid,
      "createdAt": time,
      "id": ref.documentID
    });

    getUserCards();
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