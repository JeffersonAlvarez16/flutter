import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import "package:radioklais/Programacion/bloc/bloc_programacion.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReproductoRadio extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ReproductoRadio();
  }
}

class _ReproductoRadio extends State<ReproductoRadio> {
  ProgramacionBloc programacionBloc;
  String timePosition;
  bool enVivo = false;
  DocumentSnapshot items;
  List<DocumentSnapshot> auspiciantes;
  UserBloc userBloc;

  @override
  void initState() {
    super.initState();
  }

  openUrl({
    @required String url,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Scaffold(
                appBar: AppBar(
                  actions: <Widget>[Text("")],
                ),
                body: WebView(
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                ),
              )),
    );
  }

  launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  Widget auspiciantesA(BuildContext context, double width) {
    return StreamBuilder(
        stream: Firestore.instance.collection("auspiciantes").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: width,
              height: 200.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.data.documents.length == 0) {
            return Text("Esta vacio");
          } else {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              // Let the ListView know how many items it needs to build.
              itemCount: snapshot.data.documents.length,
              // Provide a builder function. This is where the magic happens.
              // Convert each item into a widget based on the type of item it is.
              itemBuilder: (context, index) {
                final item = snapshot.data.documents[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 0.0),
                  width: (width - 150.0),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Image(
                          width: 325.0,
                          image: NetworkImage("${item["foto"]}"),
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(left: 40.0, right: 10.0, top: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Redes sociales:",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14.0,
                                    fontFamily: "Ubuntu"),
                              ),
                            ),
                            if (item['facebook'].length > 0)
                              Container(
                                  width: 30.0,
                                  height: 30.0,
                                  child: IconButton(
                                      padding: EdgeInsets.all(0.0),
                                      icon: Icon(
                                        FontAwesomeIcons.facebook,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        openUrl(url: item['facebook']);
                                      })),
                            if (item['instagram'].length > 0)
                              Container(
                                  width: 30.0,
                                  child: IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.instagram,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        openUrl(url: item['instagram']);
                                      })),
                            if (item['whatsapp'].length > 0)
                              Container(
                                width: 30.0,
                                child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    launchWhatsApp(
                                        phone: "${item['whatsapp']}",
                                        message: "Hola ...");
                                  },
                                ),
                              ),
                            if (item['twitter'].length > 0)
                              Container(
                                  width: 35.0,
                                  child: IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.twitter,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        openUrl(url: item['twitter']);
                                      })),
                            if (item['tienda'].length > 0)
                              Container(
                                  width: 30.0,
                                  child: IconButton(
                                      icon: Image(
                                        image: new AssetImage(
                                            "assets/images/tienda.png"),
                                        color: null,
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                      ),
                                      onPressed: () {
                                        openUrl(url: item['tienda']);
                                      })),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
        });
  }

  Widget programaActual(BuildContext context, double width) {
    return StreamBuilder(
        stream: Firestore.instance.collection("programa_actual").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: width,
              height: 400.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            items = snapshot.data.documents[0];
            userBloc.titulo = items['titulo'];
            userBloc.horario = items['horario'];
            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Center(
                      child: Text(
                        "${items["titulo"]}",
                        style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.white,
                            fontFamily: "Ubuntu"),
                      ),
                    ),
                  ),
                  Container(
                    width: width,
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 300.0,
                              height: 285.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage("${items["foto"]}"),
                                  ),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                      bottomLeft: Radius.circular(80.0),
                                      bottomRight: Radius.circular(80.0))),
                              child: null /* add child content here */,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15.0),
                            height: 300.0,
                            child: Center(
                              child: Container(
                                height: 300.0,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 160.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40.0),
                                    color: Colors.black,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Flash(
                                          infinite: true,
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 12.0,
                                                height: 12.0,
                                                margin:
                                                    EdgeInsets.only(right: 8.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color: Colors.red[900]),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    right: 16.0),
                                                child: Text(
                                                  "EN VIVO",
                                                  style: TextStyle(
                                                      fontSize: 10.0,
                                                      color: Colors.red[900],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${items["tiempo"]}",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white30,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        });
  }

  Widget build(BuildContext context) {
    programacionBloc = BlocProvider.of<ProgramacionBloc>(context);
    userBloc = BlocProvider.of<UserBloc>(context);
    double width = MediaQuery.of(context).size.width;

    return Stack(
      children: <Widget>[
        Container(
          color: Colors.black87,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  programaActual(context, width),
                  Container(
                    margin: EdgeInsets.only(bottom: 4.0),
                    padding: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Text(
                      "Auspiciantes",
                      style: TextStyle(color: Colors.white70, fontSize: 20.0),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 24.0),
                    padding: EdgeInsets.only(left: 37.0, top: 20.0,right: 37.0
                    ),
                    height: 250,
                    child: WebView(
                      initialUrl: "https://view-banners.now.sh",
                      javascriptMode: JavascriptMode.unrestricted,
                    ),
                  ),
                  auspiciantesA(context, width),
                ],
              )),
        ),
      ],
    );
  }
}
