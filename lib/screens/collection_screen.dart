import 'package:app/ScheduleGenerator.dart';
import 'package:app/screens/CollectionDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/constants.dart';
import 'package:app/Models.dart';

class CollectionScreen extends StatefulWidget {

  static String id = "collectionScreen";

  @override
  _CollectionScreenState createState() => _CollectionScreenState();

  CollectionScreen();

}


class _CollectionScreenState extends State<CollectionScreen> {

  List<Payment> _payments = List<Payment>();
  List<DocumentSnapshot> listP;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUserPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text("My Collections"),
          ),
          body: Stack(
                children: <Widget>[
                  _payments.isEmpty
                      ? Container(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Text(
                      "You do not have any collection yet",
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 70),
                    itemBuilder: (BuildContext context, int index) {
                      var coop = _payments[index];

                      return GestureDetector(
                        onTap: () => collectionTaped(coop),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            height: 61.0,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          coop.coopName,
                                          style: TextStyle(
                                              color: Colours.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20
                                          ),
                                        ),

                                        Text(
                                          getDate(coop.date),
                                          style: TextStyle(
                                              color: Colours.primary,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15
                                          ),
                                        )
                                      ],

                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "NGN${coop.amount}",
                                        ),
                                        Text(
                                          coop.isPaid ? "Recieved" : "Not recieved yet",
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        //onTap: () => onCoopTapped(coop),
                      );
                    },
                    itemCount: _payments.length,
                  ),
                ],
              ),
          );
    }

  String getDate(int time){
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(time*1000);
    String dateTime = "${date.day}/${date.month}/${date.year}";
    return dateTime;
  }

  Function collectionTaped(Payment p){
    Navigator.pushNamed(context, CollectionDetailsScreen.id, arguments: p);
  }

  Future<List<Widget>> getUserPayments() async {

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(Database.COLLECTION)
        .where("userId", isEqualTo: localUser.id)
        .orderBy("date")
        .getDocuments();

    listP = querySnapshot.documents;

    _payments = listP.map((doc) => Payment(doc.data)).toList();


    setState(() {
    });
  }
}