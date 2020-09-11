import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radioklais/Programacion/ui/widget/home_radio.dart';
import 'package:radioklais/Programacion/ui/widget/programacion_semanal.dart';
import 'package:radioklais/User/ui/screens/sign_in.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeKlais extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _KlaisRadio();
  }
}

class _KlaisRadio extends State<HomeKlais> {
  int indexTap = 0;
  DocumentSnapshot items;
  int currentIndex = 0;
  int tiempo = 0;
  UserBloc userBloc;
  String fecha = "";
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final availableLocalesForDateFormatting = const [
    "es_ES",
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    AudioPlayer.setIosCategory(IosCategory.playback);
    initializeDateFormatting();
    var date = DateTime.now();
    // prints Tuesday
    fecha = DateFormat.yMMMMEEEEd('es_ES').format(date);
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message['data']);
        if (message['data']['title'] == "promo") {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: Colors.black87,
                    content: Container(
                      height: 250.0,
                      child: ListTile(
                          title: Text(message['notification']['title'],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Ubuntu",
                                  fontSize: 20.0)),
                          subtitle: Container(
                            width: 250.0,
                            height: 200.0,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 6.0, bottom: 6.0),
                                  child: Text(message['notification']['body'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Ubuntu",
                                          fontSize: 16.0)),
                                ),
                                Image(
                                  width: 250.0,
                                  height: 140.0,
                                  image: NetworkImage(message['data']['image']),
                                )
                              ],
                            ),
                          )),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Aceptar"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _fcm.getToken().then((values) => {
          Firestore.instance
              .collection("dispositivos_registrados")
              .where("token", isEqualTo: values)
              .getDocuments()
              .then((value) => {
                print(value.documents.isNotEmpty),
                if(value.documents.isNotEmpty){

                }else{
                  Firestore.instance.collection("dispositivos_registrados").add({
                    "token":values
                  })
                }
              })
        });
    super.initState();
  }

  void onTapTapped(int index) {
    setState(() {
      indexTap = index;
    });
  }

  final List<Widget> widgetsChildren = [
    HomeRadioReproductor(),
    ProgramacionSemanal(),
  ];

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    if (userBloc.estadoPlayer == null) {
      Firestore.instance.collection('url_radio').document('zYyzvRK930WDEZTEjhSD')
          .get().then((DocumentSnapshot) =>{
      userBloc.player.setUrl(
      DocumentSnapshot.data['url'].toString())
    }
      );


    }
    return Scaffold(
      drawer: _handleCurrentSesion(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          Image(
            image: AssetImage("assets/images/klais-radio-logo.png"),
            width: 45.0,
          )
        ],
        title: Container(
          child: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'KLAIS RADIO',
                    style: TextStyle(fontSize: 20.0, fontFamily: "Ubuntu"),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    "$fecha",
                    style: TextStyle(fontSize: 14.0, fontFamily: "Ubuntu"),
                    textAlign: TextAlign.start,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      body: widgetsChildren[indexTap],
      bottomNavigationBar: Container(
        color: Colors.black87,
        child: Container(
          height: 146,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30.0),
              topRight: const Radius.circular(30.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30.0),
                    topRight: const Radius.circular(30.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder(
                              stream: Firestore.instance
                                  .collection("programa_actual")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 46.0,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                } else {
                                  items = snapshot.data.documents[0];
                                  return Container(
                                    height: 50.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 8.0, bottom: 8.0),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20.0),
                                                    child: Text(
                                                      items['titulo'],
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontFamily: "Ubuntu",
                                                          fontSize: 16.0),
                                                    )),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Text(
                                                    items['horario'],
                                                    style: TextStyle(
                                                        color: Colors.white60,
                                                        fontFamily: "Ubuntu"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }),
                          StreamBuilder<Duration>(
                            stream: userBloc.player.durationStream,
                            builder: (context, snapshot) {
                              return StreamBuilder<Duration>(
                                stream: userBloc.player.getPositionStream(),
                                builder: (context, snapshot) {
                                  var position = snapshot.data ?? Duration.zero;
                                  return SeekBar(
                                    duration: position,
                                    position: position,
                                    onChangeEnd: (newPosition) {
                                      userBloc.player.seek(newPosition);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<FullAudioPlaybackState>(
                      stream: userBloc.player.fullPlaybackStateStream,
                      builder: (context, snapshot) {
                        final fullState = snapshot.data;
                        final state = fullState?.state;
                        final buffering = fullState?.buffering;
                        if (userBloc.estadoPlayer == null) {
                          userBloc.estadoRadio = state;
                          userBloc.estadoPlayer = AudioPlaybackState.connecting;
                        }
                        return Row(mainAxisSize: MainAxisSize.min, children: [
                          if (userBloc.estadoRadio == userBloc.estadoPlayer ||
                              buffering == true)
                            Container(
                              margin: EdgeInsets.all(8.0),
                              width: 30.0,
                              height: 30.0,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.red[900],
                              ),
                            )
                          else if (AudioPlaybackState.stopped ==
                              userBloc.estadoRadio)
                            Container(
                              child: FloatingActionButton(
                                child: Icon(
                                  FontAwesomeIcons.play,
                                  color: Colors.red[900],
                                  size: 25.0,
                                ),
                                onPressed: () {
                                  userBloc.tiempo = 0;
                                  userBloc.estadoRadio =
                                      AudioPlaybackState.playing;
                                  userBloc.player.play();
                                },
                                backgroundColor: Colors.black,
                              ),
                            )
                          else if (AudioPlaybackState.paused ==
                              userBloc.estadoRadio)
                            Container(
                                child: FloatingActionButton(
                              child: Icon(
                                FontAwesomeIcons.play,
                                color: Colors.red[900],
                                size: 25.0,
                              ),
                              onPressed: () {
                                userBloc.tiempo = 0;
                                userBloc.estadoRadio =
                                    AudioPlaybackState.playing;
                                userBloc.player.play();
                              },
                              backgroundColor: Colors.black,
                            ))
                          else if (AudioPlaybackState.playing ==
                              userBloc.estadoRadio)
                            Container(
                                child: FloatingActionButton(
                              child: Icon(
                                FontAwesomeIcons.pause,
                                color: Colors.red[900],
                                size: 25.0,
                              ),
                              onPressed: () {
                                userBloc.estadoRadio =
                                    AudioPlaybackState.paused;
                                userBloc.tiempo = 0;
                                userBloc.player.stop();
                              },
                              backgroundColor: Colors.black,
                            ))
                          else if (userBloc.estadoRadio ==
                              AudioPlaybackState.completed)
                            Container(
                                child: FloatingActionButton(
                              child: Icon(
                                FontAwesomeIcons.play,
                                color: Colors.red[900],
                                size: 25.0,
                              ),
                              onPressed: () {
                                var dura = Duration(
                                    hours: 0,
                                    minutes: 0,
                                    seconds: 0,
                                    milliseconds: 0);
                                userBloc.player.seek(dura);
                                userBloc.player.play();
                                userBloc.estadoRadio =
                                    AudioPlaybackState.completed;
                                userBloc.tiempo = 0;
                              },
                            ))
                          else
                            Container(
                              child: FloatingActionButton(
                                child: Icon(
                                  FontAwesomeIcons.play,
                                  color: Colors.red[900],
                                  size: 25.0,
                                ),
                                onPressed: () {
                                  userBloc.estadoRadio =
                                      AudioPlaybackState.playing;
                                  userBloc.tiempo = 0;
                                  userBloc.player.play();
                                },
                                backgroundColor: Colors.black,
                              ),
                            ),
                        ]);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 56,
                color: Colors.transparent,
                child: BottomNavyBar(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  backgroundColor: Colors.black,
                  selectedIndex: indexTap,
                  showElevation: true,
                  // use this to remove appBar's elevation
                  onItemSelected: (index) => setState(() {
                    indexTap = index;
                  }),
                  items: [
                    BottomNavyBarItem(
                      icon: Icon(
                        FontAwesomeIcons.volumeUp,
                        size: 20.0,
                      ),
                      title: Text(
                        'EN VIVO',
                        style: TextStyle(fontSize: 12.0, fontFamily: "Ubuntu"),
                      ),
                      activeColor: Colors.red[900],
                    ),
                    BottomNavyBarItem(
                        textAlign: TextAlign.center,
                        icon: Icon(FontAwesomeIcons.clock, size: 20.0),
                        title: Text(
                          'PROGRAMACIÓN',
                          style:
                              TextStyle(fontSize: 12.0, fontFamily: "Ubuntu"),
                        ),
                        activeColor: Colors.red[900]),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget drawer(AsyncSnapshot snapshot) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 160.0,
            child: DrawerHeader(
                child: drawerHeader(snapshot),
                decoration: BoxDecoration(
                  color: Colors.black,
                )),
          ),
          ListTile(
            leading: Icon(
              Icons.person_pin,
            ),
            title: Text(
              'Perfil',
              style: TextStyle(fontFamily: "ubuntu", fontSize: 16.0),
            ),
            onTap: () {
              userBloc.signOut();
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(fontFamily: "ubuntu", fontSize: 16.0),
            ),
            onTap: () {
              userBloc.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _handleCurrentSesion() {
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snaphot) {
        if (!snaphot.hasData || snaphot.hasError) {
          return SignInScreen();
        } else {
          return drawer(snaphot);
        }
      },
    );
  }

  Widget drawerHeader(AsyncSnapshot snapshot) {
    if (!snapshot.hasData || snapshot.hasError) {
      return CircularProgressIndicator();
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
        height: 50.0,
        child: Row(
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
              margin: EdgeInsets.only(right: 20.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(snapshot.data.photoUrl))),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: Text(snapshot.data.displayName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                        ))),
                Text(snapshot.data.email,
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white30,
                        fontFamily: 'Ubuntu')),
              ],
            ),
          ],
        ),
      );
    }
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      child: Slider(
        activeColor: Colors.red[900],
        inactiveColor: Colors.red[100],
        min: 0.0,
        max: widget.duration.inMilliseconds.toDouble(),
        value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
        onChanged: (value) {
          setState(() {
            _dragValue = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged(Duration(milliseconds: value.round()));
          }
        },
        onChangeEnd: (value) {
          _dragValue = null;
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd(Duration(milliseconds: value.round()));
          }
        },
      ),
    );
  }
}
