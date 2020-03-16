import 'dart:async';

import 'package:app/constants.dart';
import 'package:app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:math';
import 'registration_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();

}

class _WelcomeScreenState extends State<WelcomeScreen> {

  var controller = PageController();
  var currentPageValue = 0.0;
  var firstBtnText = "Skip";
  var secondBtnText = "Next";
  var _loading = true;

  @override
  void initState() {

    super.initState();
    checkUser();

  }

  @override
  Widget build(BuildContext context) {

    controller.addListener(() {
      setState(() {
        if(controller.page > 0){
          firstBtnText = "Prev";
        }else{
          firstBtnText = "Skip";
        }

        if(controller.page == 2){
          secondBtnText = "Register";
        }else{
          secondBtnText = "Next";
        }
      });
    });

    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        body:  Stack(
          children: <Widget>[
            new PageView(
            controller: controller,
              children: <Widget>[
                Container(
                  color: Color(0xFFFBF2F2),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: <Widget>[
                      Image.asset('images/png.png', width: 200, height: 100,),
//                      Text(
//                        'Smart Ajo',
//                        style: TextStyle(
//                            fontSize: 26,
//                            fontWeight: FontWeight.bold,
//                            color: Color(0xFF1E0763)
//                        ),
//                      ),
//                      SizedBox(
//                        height: 5,
//                      ),
//                      Text(
//                        "Africa’s first Rotating Savings Club",
//                        style: TextStyle(
//                            fontSize: 16,
//                            fontWeight: FontWeight.bold,
//                            color: Color(0xFF1E0763)
//                        ),
                      //)

                    ],
                  ),

                ),
                Container(
                  color: Color(0xFFF0F5F5),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: <Widget>[
                      Image.asset('images/money.png', width: 80, height: 80,),
                      SizedBox(height: 10,),
                      Text(
                        'Contributions',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E0763)
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Manage members savings with Ease",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E0763)
                        ),
                      )

                    ],
                  ),

                ),
                Container(
                  color: Color(0xFFD8FFEC),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: <Widget>[
                      Image.asset('images/big_data.png', width: 80, height: 80,),
                      SizedBox(height: 10,),
                      Text(
                        'Reporting',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E0763)
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Get Accurate banking and transaction reports",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E0763)
                        ),
                      )

                    ],
                  ),

                ),
              ],
            ),
            new Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  FlatButton(
                    child: Text(
                      firstBtnText,
                      style: TextStyle(
                          color: Color(0xFF1E0763),
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      if(controller.page == 0){
                        Navigator.pushReplacementNamed(context, LoginScreen.id);
                      }else{
                        controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                      }
                    },
                  ),

                  DotsIndicator(
                    controller: controller,
                    itemCount: 3,
                    color: Color(0xFFBDBAC7),
                  ),

                  FlatButton(
                    child: Text(
                      secondBtnText,
                      style: TextStyle(
                          color: Color(0xFF1E0763),
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () {
                      if(controller.page == 2){
                        Navigator.pushReplacementNamed(context, RegistrationScreen.id);
                      }else{
                        controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                      }

                    },
                  ),
                ],
              ),
            ),
        ]
      )),
    );
  }

  Future<void> checkUser() async{
    FirebaseUser user = await MyAppClient().getCurrentUser();
    final prefs = await SharedPreferences.getInstance();

    if(user == null && (prefs.getBool(Constants.FIRST_TIMER) ?? true)){
      setState(() {
        _loading = false;
      });
      setupPrefs();
    }else if(user == null && !(prefs.getBool(Constants.FIRST_TIMER) ?? true)){
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }else{
      Navigator.pushReplacementNamed(context, ChatScreen.id);
    }
  }

  Future<void> setupPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.FIRST_TIMER, false);
  }
}



/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {

  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.5;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
