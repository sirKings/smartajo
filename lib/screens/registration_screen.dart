import 'package:app/Models.dart';
import 'package:app/screens/chat_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';

class RegistrationScreen extends StatefulWidget {

  static String id = "registrationScreen";




  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  var _auth = FirebaseAuth.instance;
  var _store = Firestore.instance;

  var email = "";
  var pass = "";
  var pass1 = "";
  var phone = "";
  var name = "";
  var _validateName = false;
  var _validatePass = false;
  var _validatePass1 = false;
  var _validatePhone = false;
  var _validateEmail = false;
  var _loading = false;
  bool passOscured = true;
  bool passObscured = true;

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
                  name = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Image.asset("images/person.png"),
                  errorText: _validateName ? 'Field can not be empty' : null,
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  phone = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  prefixIcon: Image.asset("images/phone.png"),
                  errorText: _validatePhone ? 'Field can not be empty' : null,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 12.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Image.asset("images/mail.png"),
                  errorText: _validateEmail ? 'Field can not be empty' : null,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 12.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  pass = value;
                },
                obscureText: passOscured,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Image.asset("images/lock.png"),
                  errorText: _validatePass ? 'Field can not be empty' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      passOscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        passOscured = !passOscured;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 12.0,
              ),
              TextField(
                onChanged: (value) {
                  //Do something with the user input.
                  pass1 = value;
                },
                obscureText: passObscured,
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  prefixIcon: Image.asset("images/lock.png"),
                  errorText: _validatePass1 ? 'Passwords does not match' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      passObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      // Update the state i.e. toogle the state of passwordVisible variable
                      setState(() {
                        passObscured = !passObscured;
                      });
                    },
                  ),
                ),
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
                      //Implement registration functionality.
                      validate();
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Register',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ),
              ),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Already have an account? Signin"
                ),
                onPressed: (){
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> validate() async {

    print(_validateName);
    print(_validatePass);
    print(_validatePhone);
    print(_validateEmail);

    setState(() {
      if(name.isEmpty){
        _validateName = true;
      }else{
        _validateName = false;
      }

      if(phone.isEmpty){
        _validatePhone = true;
      }else{
        _validatePhone = false;
      }

      if(pass.isEmpty){
        _validatePass = true;
      }else{
        _validatePass = false;
      }

      if(pass != pass1){
        _validatePass1 = true;
      }else{
        _validatePass1 = false;
      }

      if(email.isEmpty){
        _validateEmail = true;
      }else{
        _validateEmail = false;
      }

    });

    if(!_validatePass && !_validateEmail && !_validatePhone && !_validateName && !_validatePass1){

      setState(() {
        _loading = true;
      });


      await _auth.createUserWithEmailAndPassword(email: email, password: pass).then((user) {

            setState(() {
             _loading = false;
            });

            saveUser(user.user.uid);

      }).catchError((err){
        PlatformException e = err as PlatformException;
        setState(() {
          _loading = false;
        });

        _alert(e.message);
      });


    }

  }

  Future<bool> saveUser(String id) async {

    await _store.collection(Database.USERS).document(id).setData
        ({
      'name': name,
      'phone': phone,
      'email': email,
      'id': id
    });

    await MyAppClient().getCurrentUser();

    setState(() {
      _loading = false;
    });

    Navigator.pushReplacementNamed(context, ChatScreen.id);

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

}
