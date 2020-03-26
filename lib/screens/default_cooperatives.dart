
import 'package:app/screens/JoinCoopScreen.dart';
import 'package:app/screens/PaymentScreen.dart';
import 'package:app/screens/collection_screen.dart';
import 'package:app/screens/create_cooperative_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/Models.dart';
import 'coop_details_screen.dart';

class DefaultCoopsScreen extends StatefulWidget {
  static String id = "DefaultCoopsScreen";
  @override
  _DefaultCoopsState createState() => _DefaultCoopsState();
}

class _DefaultCoopsState extends State<DefaultCoopsScreen> {
  var _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> list;
  List<DocumentSnapshot> listP;
  List<Coop> _coops = List<Coop>();
  List<Payment> _payments = List<Payment>();
  var _loading = true;

  var name = localUser.name;
  var email = localUser.email;
  var initials = localUser.getInitiials();
  var uid = localUser.id;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {

    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Find Cooperatives'),
        ),
        body: Stack(
              children: <Widget>[

                StreamBuilder(
                    stream: Firestore.instance
                        .collection(Database.DEFAULT_COOPERATIVES)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                          child: Text(
                            "Loading..",
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        List<DocumentSnapshot> items = snapshot.data.documents;

                        return
//                          items.isEmpty
//                            ? Container(
//                          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
//                          child: Text(
//                            "You don't belong to any cooperative yet",
//                            textAlign: TextAlign.center,
//                          ),
//                        )
//                            :
                        ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                          itemBuilder: (BuildContext context, int index) {
                            var coop = Coop(items[index].data);
                            return ListTile(
                              isThreeLine: true,
                              leading: CircleAvatar(
                                child: Text(
                                  coop.getAvartar(),
                                  style: TextStyle(
                                      color: Colours.primary
                                  ),
                                ),
                                backgroundColor: Colours.ash,
                              ),
                              title: Text(coop.name),
                              subtitle: Text('Created by ${coop.creatorName} \n NGN${coop.amount}.00'),
                              trailing: Text(
                                  "Code: ${coop.code}"
                              ),
                              onTap: () => onCoopTapped(coop),
                            );

                          },
                          itemCount: items.length,
                        );
                      }}),
//                Positioned(
//                  left: 10.0,
//                  right: 10.0,
//                  bottom: 10.0,
//                  child: MaterialButton(
//                      elevation: 5,
//                      color: Color(0xFF1E0763),
//                      child: Text(
//                        "Create new cooperative",
//                        style: TextStyle(
//                          color: Colors.white,
//                        ),
//                      ),
//                      onPressed: () {
//                        Navigator.pushNamed(context, CreateCoopScreen.id);
//                      }),
//                )
              ],
            ),
        ),
      );
  }

  Function onCoopTapped(Coop coop) {
    CoopDetailsPageArgument arg = CoopDetailsPageArgument();
    arg.coop = coop;
    arg.isJoining = true;
    Navigator.pushNamed(context, CoopDetailsScreen.id, arguments: arg);
  }

  String getDate(int time){
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(time*1000);
    String dateTime = "${date.day}/${date.month}/${date.year}";
    return dateTime;
  }

}