import 'package:app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'chat_screen.dart';


class LoginScreen extends StatefulWidget {

  static String id = "LoginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var _auth = FirebaseAuth.instance;

  var email = "";
  var pass = "";
  var _validatePass = false;
  var _validateEmail = false;
  var _loading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _loading,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: ListView(
            children: <Widget>[

              SizedBox(
                height: 120.0,
              ),
              Container(
                height: 80.0,
                width: 80.0,
                child: Image.asset('images/png.png'),
              ),
              SizedBox(
                height: 48.0,
              ),

              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                    errorText: _validateEmail ? 'Field can not be empty' : null,
                  prefixIcon: Image.asset("images/person.png")
//                contentPadding:
//                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                border: OutlineInputBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                ),
//                enabledBorder: OutlineInputBorder(
//                  borderSide:
//                      BorderSide(color: Colors.lightBlueAccent, width: 1.0),
//                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                ),
//                focusedBorder: OutlineInputBorder(
//                  borderSide:
//                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
//                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  pass = value;
                },
                decoration: InputDecoration(
                    hintText: 'Enter your password.',
                    prefixIcon: Image.asset("images/lock.png"),
                    errorText: _validatePass ? 'Field can not be empty' : null,

                ),
                obscureText: true,
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Color(0xFF1E0763),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () {
                      //Implement login functionality.
                      validate();
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Log In',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                    "Don't have an account? Register"
                ),
                onPressed: (){
                  Navigator.pushReplacementNamed(context, RegistrationScreen.id);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _alert(String err) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(err),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> validate() async {


    setState(() {

      if(pass.isEmpty){
        _validatePass = true;
      }else{
        _validatePass = false;
      }

      if(email.isEmpty){
        _validateEmail = true;
      }else{
        _validateEmail = false;
      }

    });

    if(!_validatePass && !_validateEmail){

      setState(() {
        _loading = true;
      });


      await _auth.signInWithEmailAndPassword(email: email, password: pass).then((user) {

        setState(() {
          _loading = false;
        });

        Navigator.pushNamed(context, ChatScreen.id);

      }).catchError((err) {
          PlatformException e = err as PlatformException;
          _alert(e.message);


        setState(() {
          _loading = false;
        });
        print(err);

      });


    }

  }
}
