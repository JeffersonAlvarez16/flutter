import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:radioklais/home.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  State createState() {
    return _SignInScreen();
  }
}

class _SignInScreen extends State<SignInScreen> {
  UserBloc userBloc;
  @override
  final myController = TextEditingController();
  bool view_password = true;
  Widget build(BuildContext context) {
    // TODO: implement build
    userBloc = BlocProvider.of(context);

    return singInGoogleUI();
  }

  Widget _handleCurrentSesion(){

  }

  Widget singInGoogleUI() {
    final registrate = Text("Inicia sesión con:",
        style: TextStyle(
          color: Colors.white,
          fontFamily: "ubuntu",
          fontSize: 18.0,
        ));

    final photoKlias = Container(
      width: 175.0,
      height: 175.0,
      margin: EdgeInsets.only(top: 50.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/klais-radio-logo.png"))),
    );

    final butongoogle = InkWell(
      onTap: () {
        userBloc.signIn().then(
            (FirebaseUser user) => print("el usuario es  ${user.displayName}"));
      },
      child: Container(
          height: 51.0,
          width: 262.0,
          decoration: new BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(40.0),
          ),
          margin: EdgeInsets.only(
            top: 30.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Ingresa con Google",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: "ubuntu",
                  )),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ))),
    );
    final butonfacebook = InkWell(
      onTap: () {},
      child: Container(
          height: 51.0,
          width: 262.0,
          decoration: new BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(40.0),
          ),
          margin: EdgeInsets.only(
            top: 30.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Ingresa con Facebook",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: "ubuntu",
                  )),
              Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ))),
    );
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeKlais()),
              );
            },
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(minWidth: width, maxWidth: width),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
              child: null,
            ),
            Column(
              children: <Widget>[photoKlias, butonfacebook, butongoogle],
            ),
          ],
        ));
  }
}
