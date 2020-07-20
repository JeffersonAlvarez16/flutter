import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    AudioPlayer.setIosCategory(IosCategory.playback);

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
    // TODO: implement build
    userBloc = BlocProvider.of<UserBloc>(context);
    if (userBloc.estadoPlayer == null) {
      userBloc.player.setUrl(
          "https://adminradio.klais.ec/radio/8020/radio.mp3?1593215539");
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
                    'Lunes 21 de Junio',
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
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
                              onPressed: () {
                                userBloc.tiempo = 0;
                                userBloc.estadoRadio =
                                    AudioPlaybackState.playing;
                                userBloc.player.play();
                              },
                            )
                          else if (AudioPlaybackState.paused ==
                              userBloc.estadoRadio)
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
                              onPressed: () {
                                userBloc.tiempo = 0;
                                userBloc.estadoRadio =
                                    AudioPlaybackState.playing;
                                userBloc.player.play();
                              },
                            )
                          else if (AudioPlaybackState.playing ==
                              userBloc.estadoRadio)
                            IconButton(
                              icon: Icon(
                                Icons.pause,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
                              onPressed: () {
                                userBloc.estadoRadio =
                                    AudioPlaybackState.paused;
                                userBloc.tiempo = 0;
                                userBloc.player.stop();
                              },
                            )
                          else if (userBloc.estadoRadio ==
                              AudioPlaybackState.completed)
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
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
                            )
                          else
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
                              onPressed: () {
                                userBloc.estadoRadio =
                                    AudioPlaybackState.playing;
                                userBloc.tiempo = 0;
                                userBloc.player.play();
                              },
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
                  showElevation: true, // use this to remove appBar's elevation
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
