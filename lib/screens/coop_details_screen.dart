
import 'package:app/ScheduleGenerator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:app/constants.dart';
import 'package:app/Models.dart';
import 'PaymentScreen.dart';

class CoopDetailsScreen extends StatefulWidget {

  static String id = "coopDetails";

  CoopDetailsPageArgument arguments;

  @override
  _CoopDetailsState createState() => _CoopDetailsState(arguments);

  CoopDetailsScreen(this.arguments);

}

var _loading = false;

class _CoopDetailsState extends State<CoopDetailsScreen> {

  CoopDetailsPageArgument arguments;

  _CoopDetailsState(this.arguments);

  Firestore _store = Firestore.instance;

  List<CMember> _members = List<CMember>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getMembers();
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
                  text: "Summary",
                ),
                Tab(
                  text: "Members",
                ),
              ],
            ),
            title: Text(arguments.coop.name),
          ),
          body: TabBarView(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Code: ${arguments.coop.code}",
                            style: TextStyle(
                              color: Colours.primary,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 80,
                        ),

                        CircleAvatar(
                         backgroundColor: Colours.touquise,
                          radius: 120,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 110,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "NGN${int.parse(arguments.coop.amount) * int.parse(arguments.coop.number)}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colours.primary
                                  ),
                                ),
                                Text(
                                  "Total Contribution Amount",
                                  style: TextStyle(
                                    color: Colours.primary
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: arguments.isJoining ? 70 : 100,
                        ),

                        Container(
                          height: 30.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colours.touquise,
                                    radius: 10,
                                    child: Text(
                                        ""
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Contribution per member:",
                                    style: TextStyle(
                                        color: Colours.touquise,
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "NGN${arguments.coop.amount}",
                                style: TextStyle(
                                  color: Colours.touquise,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.black26,
                        ),
                        Container(
                          height: 30.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: Colours.primary,
                                    radius: 10,
                                    child: Text(
                                        ""
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Total members:",
                                    style: TextStyle(
                                      color: Colours.primary,
                                      fontWeight: FontWeight.bold,

                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${arguments.coop.number}",
                                style: TextStyle(
                                  color: Colours.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),

                      ],
                    )
                  ),
                  Positioned(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                    child: arguments.isJoining ?  MaterialButton(
                        elevation: 5,
                        color: Color(0xFF1E0763),
                        child: Text(
                          "Join cooperative",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if(localUser.chargeCode == null || localUser.chargeCode.isEmpty){
                            _chargeAlert();
                          }else {
                            setState(() {
                              _loading = true;
                            });
                            joinCoop();
                          }
                        })
                        : Container(width: 0.0,height: 0.0,)
                  )
                ],
              ),
              Stack(
                children: <Widget>[
                  _members.isEmpty
                      ? Container(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Text(
                      "Loading members..",
                      textAlign: TextAlign.center,
                    ),
                  )
                      : ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      var coop = _members[index];

                      return Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        height: 96.0,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colours.ash,
                                  radius: 30,
                                  child: Text(
                                    coop.getInitiials(),
                                    style: TextStyle(
                                      color: Colours.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      coop.name,
                                      style: TextStyle(
                                        color: Colours.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                      ),
                                    ),
//                                    Text(
//                                      coop.email,
//                                      style: TextStyle(
//                                          color: Colours.primary,
//                                          fontWeight: FontWeight.normal,
//                                          fontSize: 16
//                                      ),
//                                    ),
                                    Text(
                                      "${arguments.coop.getAvartar()} 000${coop.position + 1}",
                                      style: TextStyle(
                                          color: Colours.primary,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15
                                      ),
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
                    itemCount: _members.length,
                  ),
                  Positioned(
                      left: 10.0,
                      right: 10.0,
                      bottom: 10.0,
                      child: arguments.isJoining ?  MaterialButton(
                          elevation: 5,
                          color: Color(0xFF1E0763),
                          child: Text(
                            "Join cooperative",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if(localUser.chargeCode == null || localUser.chargeCode.isEmpty){
                              _chargeAlert();
                            }else {
                              setState(() {
                                _loading = true;
                              });
                              joinCoop();
                            }
                          })
                          : Container(width: 0.0,height: 0.0,)
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future _getMembers() async{

    var message = "";

    try{
      QuerySnapshot members = await _store.collection(Database.MEMBERS).where(Database.COOPSID, isEqualTo: arguments.coop.id).getDocuments();

      if(members.documents.isNotEmpty){
        members.documents.forEach((doc) {
          _members.add(CMember(doc.data));
        });
        _members.sort((a,b) => a.position.compareTo(b.position));
        setState(() {

        });
      }
    }catch (e){
      message = "Could not load members, Try again later";
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
    }

  }

  Future<void> _chargeAlert() async {
    BuildContext ctx = context;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You need to add payment method before you can create a cooperative'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(ctx);
              },
            ),
            FlatButton(
              child: Text('Add Card'),
              onPressed: () {
                Navigator.pushNamed(ctx, PaymentScreen.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future joinCoop() async {

    print("Joining Coops");

    var message = "";

    try{

      DocumentReference ref = await _store.collection(Database.USERS).document(localUser.id).collection(Database.COOPERATIVES).add({
        "name": arguments.coop.name,
        "number": arguments.coop.number,
        "amount": arguments.coop.amount,
        "creator": arguments.coop.creator,
        "creatorName": arguments.coop.creatorName,
        "createdAt": arguments.coop.createdAt,
        "id": arguments.coop.id,
        "code": arguments.coop.code
      });

      await _store.collection(Database.MEMBERS).add({
        Database.COOPSID: arguments.coop.id,
        'name': localUser.name,
        'phone': localUser.phone,
        'email': localUser.email,
        'id': localUser.id,
        'position': _members.length
      });


      ScheduleGenerator(
          arguments.coop.startDate,
          arguments.coop.period,
          int.parse(arguments.coop.number),
          arguments.coop.amount,
          arguments.coop.id,
          _members.length,
          arguments.coop.name,
          localUser.chargeCode
      ).generateSchedule();

      message = "You have joined this cooperative";
        //message = "Cooperative found ${Coop(coop.documents[0].data).name}";
        //_formKey.currentState.reset();
    }catch(e){

      message = 'Could not join cooperative, Try again later';
    }

    _getMembers();

    setState(() {
      _loading = false;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
