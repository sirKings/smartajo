
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

class ChatScreen extends StatefulWidget {
  static String id = "chatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> list;
  List<DocumentSnapshot> listP;
  List<Coop> _coops = List<Coop>();
  List<Payment> _payments = List<Payment>();
  var _loading = true;

  var name = "";
  var email = "";
  var initials = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    MyAppClient().getCurrentUser().whenComplete(() {
      getUserCooperatives().whenComplete(() {
        setState(() {
          name = localUser.name;
          email = localUser.email;
          initials = localUser.getInitiials();
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: LoadingOverlay(
        isLoading: _loading,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "My Cooperatives",
                ),
                Tab(
                  text: "My Contributions",
                ),
              ],
            ),
            title: Text('Dashboard'),
            actions: <Widget>[
              IconButton(
                icon: Image.asset("images/menu.png"),
                onPressed: () {
                  showNav();
                },
              )
            ],
          ),
          body: TabBarView(
            children: [
              Stack(
                children: <Widget>[
                  _coops.isEmpty
                      ? Container(
                          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                          child: Text(
                            "You don't belong to any cooperative yet",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                          itemBuilder: (BuildContext context, int index) {
                            var coop = _coops[index];
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
                          itemCount: _coops.length,
                        ),
                  Positioned(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                    child: MaterialButton(
                        elevation: 5,
                        color: Color(0xFF1E0763),
                        child: Text(
                          "Create new cooperative",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, CreateCoopScreen.id);
                        }),
                  )
                ],
              ),
              Stack(
                children: <Widget>[
                  _payments.isEmpty
                      ? Container(
                          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                          child: Text(
                            "You do not have any payment yet",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 70),
                          itemBuilder: (BuildContext context, int index) {
                            var coop = _payments[index];

                            return Container(
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
                                            coop.isPaid ? "Paid" : "Not paid yet",

                                          )
                                        ],

                                      )
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.black26,
                                  )
                                ],
                              ),
                              //onTap: () => onCoopTapped(coop),
                            );
                          },
                          itemCount: _payments.length,
                        ),
                  Positioned(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                    child: MaterialButton(
                        elevation: 5,
                        color: Color(0xFF1E0763),
                        child: Text(
                          "Payment Methods",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, PaymentScreen.id);
                        }),
                  )
                ],
              ),
            ],
          ),
          endDrawer: Drawer(
            // Add a ListView to the drawer. This ensures the user can scroll
            // through the options in the drawer if there isn't enough vertical
            // space to fit everything.
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colours.ash,
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 40,
                            color: Colours.primary
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colours.ash
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          color: Colours.ash
                        ),
                      )
                    ],

                  ),
                  decoration: BoxDecoration(
                    color: Colours.primary,
                  ),
                ),
                ListTile(
                  title: Text('Join cooperative'),
                  onTap: () {
                    // Update the state of the app
                    // Then close the drawer
                    Navigator.pushNamed(context, JoinCoopScreen.id);
                  },
                ),
                ListTile(
                  title: Text('Find cooperative'),
                  onTap: () {
                    // Update the state of the app
                    // Then close the drawer
                    Navigator.pushNamed(context, JoinCoopScreen.id);
                  },
                ),
                ListTile(
                  title: Text('My Collection'),
                  onTap: () {
                    // Update the state of the app
                    // Then close the drawer
                    Navigator.pushNamed(context, CollectionScreen.id);
                  },
                ),
                ListTile(
                  title: Text('Signout'),
                  onTap: () {
                    // Update the state of the app
                    signout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Function onCoopTapped(Coop coop) {
    CoopDetailsPageArgument arg = CoopDetailsPageArgument();
    arg.coop = coop;
    arg.isJoining = false;
    Navigator.pushNamed(context, CoopDetailsScreen.id, arguments: arg);
  }

  Function showNav(){
    _scaffoldKey.currentState.openEndDrawer();
  }

  String getDate(int time){
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(time*1000);
    String dateTime = "${date.day}/${date.month}/${date.year}";
    return dateTime;
  }

  Future<List<Widget>> getUserCooperatives() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(Database.USERS)
        .document(myUser.uid)
        .collection(Database.COOPERATIVES)
        .getDocuments();

    list = querySnapshot.documents;

    _coops = list.map((doc) => Coop(doc.data))
    .toList();

    getUserPayments(myUser.uid);
  }

  Future<List<Widget>> getUserPayments(String uid) async {

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(Database.PAYMENTS)
        .where("userId", isEqualTo: localUser.id)
        .orderBy("date")
        .getDocuments();

    listP = querySnapshot.documents;

    _payments = listP.map((doc) => Payment(doc.data)).toList();

    print(_payments);

    setState(() {
      _loading = false;
    });
  }

  Function signout(){
    _auth.signOut();
    Navigator.pushReplacementNamed(context, LoginScreen.id);
  }
}
