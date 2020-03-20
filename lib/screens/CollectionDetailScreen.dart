
import 'package:app/payment_keys.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/constants.dart';
import 'package:app/Models.dart';
import 'dart:convert';


class CollectionDetailsScreen extends StatefulWidget {

  static String id = "CollectionDetailsScreen";

  Payment arguments;

  CollectionDetailsScreen(this.arguments);

  @override
  _CollectionDetailsState createState() => _CollectionDetailsState(arguments);


}



class _CollectionDetailsState extends State<CollectionDetailsScreen> {

  @override
  void initState() {
    super.initState();
  }

  Payment arguments;

  _CollectionDetailsState(this.arguments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Collection Details"),
      ),
      body: MyCustomForm(this.arguments),

    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {

  Payment arguments;

  MyCustomForm(this.arguments);


  @override
  MyCustomFormState createState() {
    return MyCustomFormState(this.arguments);
  }


}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {

  Payment arguments;

  MyCustomFormState(this.arguments);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  var _store = Firestore.instance;
  var _auth = FirebaseAuth.instance;
  var name = "Account Name";
  var amount = "";
  var number = "";
  bool nameFound = false;
  bool _loading = true;
  List<DropdownMenuItem<int>> bankList = [];
  var selectedBank;
  String bankWarning = "";
  List<Bank> listBank = [];

  @override
  void initState() {
    super.initState();
    getBanks();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        key: _scaffoldKey,
        body: ListView(
          padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
          children: <Widget>[

            CircleAvatar(
              backgroundColor: Colours.touquise,
              radius: 70,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "NGN${arguments.amount}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colours.primary
                      ),
                    ),
                    Text(
                      "Total Amount",
                      style: TextStyle(
                          color: Colours.primary,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 40,
            ),

            Form(
              
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                      number = value;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Account Number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter Account Number',
                    ),
                  ),
                  DropdownButton(
                    hint: new Text('Select Bank'),
                    items: bankList,
                    value: selectedBank,
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                        name = "Loading..";
                      });
                      resolveAccount();},

                    //isExpanded: true,
                  ),
                  Text(
                    bankWarning,
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12
                    ),
                  ),
                  TextFormField(
                    readOnly: true,

                    decoration: InputDecoration(
                      hintText: name,
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
                          if(_formKey.currentState.validate() && validate()){
                            setState(() {
                              _loading = true;
                            });
                            request();
                          }
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Request Payment',
                          style: kSendButtonTextStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }

  bool validate(){
    if(selectedBank == null){
      bankWarning = "Please select bank";
      setState(() {

      });
      return false;
    }else if(!nameFound){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Account number not resolved"),));
      return false;
    }

    return true;
  }

  Future resolveAccount() async {

    var code = listBank[selectedBank].code;


    print(number);
    print(code);

    final http.Response response = await http.get('https://api.paystack.co/bank/resolve?account_number=$number&bank_code=$code',
        headers: {
          "Authorization": "Bearer ${PaymentKeys.secretKey}"
        });
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      bool status = json.decode(response.body)["status"];

      if(status){
         name = json.decode(response.body)["data"]["account_name"];
      }

      nameFound = true;

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      nameFound = false;
      name = "Unable to resolve";
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Unable to resolve account number, Make sure you entered correct account number"),));
    }

    setState(() {
      _loading = false;
    });

  }

  Future getBanks() async {

    final http.Response response = await http.get('https://api.paystack.co/bank',
        headers: {
          "Authorization": "Bearer ${PaymentKeys.secretKey}"
        });
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      bool status = json.decode(response.body)["status"];

      if(status){
        var responseJson = json.decode(response.body);
        (responseJson['data'] as List).forEach((e) {

          bankList.add(new DropdownMenuItem(
            child: new Text(e["name"],),
            value: e["id"],

          ));

          listBank.add(Bank(e));

        });
      }

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }

    setState(() {
      _loading = false;
    });

  }

  Future request() async {
    QuerySnapshot querySnapshot = await _store
        .collection(Database.PAYMENTS)
        .where(Database.COOPSID, isEqualTo: arguments.coopId)
        .where("date", isEqualTo: arguments.date)
        .getDocuments();

    for(int i = 0; i < querySnapshot.documents.length; i++ ){
       await chargePayments(Payment(querySnapshot.documents[i].data), );
    }

    QuerySnapshot querySnapshot2 = await _store
        .collection(Database.PAYMENTS)
        .where("date", isEqualTo: arguments.date)
        .where(Database.COOPSID, isEqualTo: arguments.coopId)
        .where('isPaid', isEqualTo: true)
        .getDocuments();

    if(querySnapshot2.documents.isNotEmpty){
      debitUser(querySnapshot2.documents.length, Payment(querySnapshot2.documents[0].data));
    }else{
      setState(() {
        _loading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Could not charge members, Try again later"),));
    }

  }

  Future debitUser(int num, Payment p) async {

    final http.Response response = await http.post('https://api.paystack.co/transferrecipient',
        headers: {
          "Authorization": "Bearer ${PaymentKeys.secretKey}"
        },
        body: jsonEncode(<String, dynamic>{
          "type": "nuban",
          "name": name,
          "description": "Payment ${arguments.id}",
          "account_number": number,
          "bank_code": listBank[selectedBank].code,
          "currency": "NGN",
          "metadata": {
            "pay": "${arguments.coopId}"
          }
        }));
    print(response.body);
    bool status = json.decode(response.body)["status"];
    if (status) {

      print(response.body);

      if (status) {
        var recepientCode = json.decode(response.body)["data"]["recipient_code"];

        final http.Response response2 = await http.post('https://api.paystack.co/transfer',
            headers: {
              "Authorization": "Bearer ${PaymentKeys.secretKey}"
            },
            body: jsonEncode(<String, dynamic>{
              "source": "balance", "reason": "Payment for ${arguments.coopId}", "amount": num * 100 * p.amount, "recipient": recepientCode
            }));

        print(response2.body);
        if (response2.statusCode == 200) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.

          await _store.collection(Database.COLLECTION).document(arguments.id).updateData({
            "isPaid": true
          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Successful, Your payment have been processed"),));
        }else{
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Could not process your payment, Try again later"),));
        }

      }
    }else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Could not resolve your account details, Try again later"),));
    }

    setState(() {
      _loading = false;
    });

  }

  Future chargePayments(Payment p) async {

    print("Starting payment");
    print(p.email);

    final http.Response response = await http.post('https://api.paystack.co/transaction/charge_authorization',
        headers: {
          "Authorization": "Bearer ${PaymentKeys.secretKey}"
        },
        body: jsonEncode(<String, dynamic>{
          "authorization_code": p.chargeCode, "email": p.email, "amount": p.amount * 100
        })

    );

    //print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.

      bool status = json.decode(response.body)["status"];

      if (status) {
        var responseJson = json.decode(response.body)["data"]["status"];

        if(responseJson == "success"){
           await _store.collection(Database.PAYMENTS).document(p.id).updateData({
            'isPaid': true
          });
        }

      }
    }
  }

}