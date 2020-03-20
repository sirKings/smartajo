import 'package:app/screens/JoinCoopScreen.dart';
import 'package:app/screens/PaymentScreen.dart';
import 'package:app/screens/chat_screen.dart';
import 'package:app/screens/collection_screen.dart';
import 'package:app/screens/create_cooperative_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/registration_screen.dart';
import 'package:app/screens/welcome_screen.dart';
import 'package:app/screens/coop_details_screen.dart';
import 'constants.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF1E0763),
        accentColor: Color(0xFFFF0000),
      ),
      home: WelcomeScreen(),

      title: "Smart Ajo",
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        CreateCoopScreen.id: (context) => CreateCoopScreen(),
        PaymentScreen.id: (context) => PaymentScreen(),
        JoinCoopScreen.id: (context) => JoinCoopScreen(),
        CoopDetailsScreen.id: (context) => CoopDetailsScreen(ModalRoute.of(context).settings.arguments),
        CollectionScreen.id: (context) => CollectionScreen()
        CollectionDetailsScreen.id: (context) => CollectionDetailsScreen(ModalRoute.of(context).settings.arguments),
      },
    );
  }

}
