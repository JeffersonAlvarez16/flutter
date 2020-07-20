import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';
import 'package:date_format/date_format.dart';

class ListaProgramas extends StatefulWidget {
  List lista;

  ListaProgramas(List lista) {
    this.lista = lista;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ListaProgramas(lista);
  }
}

class _ListaProgramas extends State<ListaProgramas> {
  List lista;
  List itemSeleccionado = [];
  AudioPlayer _player;
  UserBloc userBloc;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void dispose() {
    // TODO: implement dispose
    _player.stop();
    super.dispose();
  }

  void initState() {
    AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();

    super.initState();
  }

  @override
  _ListaProgramas(List lista) {
    this.lista = lista;
  }

  void abrirAudio(String url) async {
    _player.setUrl("${url}").catchError((error) {
      // catch audio error ex: 404 url, wrong url ...
      print(error);
    });

    _player.play();
  }

  encontrarDiferencia(String fecha){
    var dateFirestore=DateTime.parse(fecha);
    print(dateFirestore);
    final fecha_progrmama =dateFirestore;
    final date2 = DateTime.now();
    final difference = date2.difference(fecha_progrmama).inDays;
    print(difference);
    return difference;
  }


  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    userBloc = BlocProvider.of<UserBloc>(context);
    Widget ProgramacionAnterior() {
      print("id entrante");
      print(lista[0]['id']);
      return new StreamBuilder(
          stream: Firestore.instance
              .collection("programas_anteriores")
              .where("id_programacion", isEqualTo: lista[0]['id'])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.data.documents.length == 0) {
              return Container(
                  width: width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.broken_image,
                        size: 30.0,
                        color: Colors.white70,
                      ),
                      Text(
                        "No hay programas anteriores",
                        style: TextStyle(
                            fontFamily: "Ubuntu",
                            fontSize: 14.0,
                            color: Colors.white70),
                      )
                    ],
                  ));
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
                  print(item['titulo']);
                  return Container(
                      margin: EdgeInsets.only(
                          bottom: 18.0, left: 40.0, right: 40.0),
                      width: width - 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '${item['titulo']}',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16.0,
                                      fontFamily: "Ubuntu"),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 4.0),
                                child: Text(
                                 '${item['date']} - ${item['duracion']}',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontFamily: "Ubuntu"),
                                ),
                              ),

                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                itemSeleccionado = [item].toList();
                              });
                              userBloc.player.pause();
                              userBloc.estadoRadio = AudioPlaybackState.paused;
                              abrirAudio("${item['audio']}");
                            },
                            child: Container(
                                padding: EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: Colors.black,
                                ),
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white70,
                                  size: 30.0,
                                )),
                          ),
                        ],
                      ));
                },
              );
            }
          });
    }

    Widget ProgramaActual() {
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
                  "${lista[0]["titulo"]}",
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
                              image:
                                  NetworkImage("${lista[0]["foto_portada"]}"),
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomLeft: Radius.circular(80.0),
                                bottomRight: Radius.circular(80.0))),
                        child: null /* add child content here */,
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

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          Image(
            image: AssetImage("assets/images/klais-radio-logo.png"),
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
      body: Stack(children: <Widget>[
        Container(
            width: width,
            height: height,
            color: Colors.black87,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ProgramaActual(),
                    Container(
                      margin: EdgeInsets.only(bottom: 4.0),
                      padding: EdgeInsets.only(left: 40.0, top: 20.0),
                      child: Text(
                        "Programas anteriores",
                        style: TextStyle(color: Colors.white70, fontSize: 20.0),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 75.0, top: 12.0),
                      child: ProgramacionAnterior(),
                    ),
                  ],
                )))
      ]),
      bottomNavigationBar: itemSeleccionado.length == 0
          ? null
          : Container(
              color: Colors.black87,
              child: Container(
                height: 105.0,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(30.0),
                    topRight: const Radius.circular(30.0),
                  ),
                ),
                child: Row(crossAxisAlignment:
                  CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                            "${itemSeleccionado[0]['titulo']}",
                            style: TextStyle(
                                color: Colors.white70,
                                fontFamily: "Ubuntu",
                                fontSize: 16.0),
                          )),
                          Container(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "Hace 5 dias, ${itemSeleccionado[0]['duracion']}",
                              style: TextStyle(
                                  color: Colors.white60, fontFamily: "Ubuntu"),
                            ),
                          ),
                          StreamBuilder<Duration>(
                            stream: _player.durationStream,
                            builder: (context, snapshot) {
                              final duration = snapshot.data ?? Duration.zero;
                              return StreamBuilder<Duration>(
                                stream: _player.getPositionStream(),
                                builder: (context, snapshot) {
                                  var position = snapshot.data ?? Duration.zero;
                                  if (position > duration) {
                                    position = duration;
                                  }
                                  return SeekBar(
                                    duration: duration,
                                    position: position,
                                    onChangeEnd: (newPosition) {
                                      _player.seek(newPosition);
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
                      stream: _player.fullPlaybackStateStream,
                      builder: (context, snapshot) {
                        final fullState = snapshot.data;
                        final state = fullState?.state;
                        final buffering = fullState?.buffering;

                        if (state == AudioPlaybackState.stopped) {
                          _player.play();
                        }
                        return Row(mainAxisSize: MainAxisSize.min, children: [
                          if (state == AudioPlaybackState.connecting ||
                              buffering == true)
                            Container(
                              margin: EdgeInsets.all(8.0),
                              width: 30.0,
                              height: 30.0,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.red[900],
                              ),
                            )
                          else if (state == AudioPlaybackState.playing)
                            IconButton(
                              icon: Icon(Icons.pause, color: Colors.red[900]),
                              iconSize: 40.0,
                              onPressed:(){
                                _player.pause();
                                userBloc.player.play();
                                userBloc.estadoRadio = AudioPlaybackState.playing;
                                },
                            )
                          else if (state == AudioPlaybackState.completed)
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
                                _player.seek(dura);
                                userBloc.player.pause();
                                userBloc.estadoRadio = AudioPlaybackState.paused;
                                _player.play();
                              },
                            )
                          else
                            IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.red[900],
                              ),
                              iconSize: 40.0,
                              onPressed: (){
                                userBloc.player.pause();
                                userBloc.estadoRadio = AudioPlaybackState.paused;
                                _player.play();
                                },
                            ),
                        ]);
                      },
                    ),
                  ],
                ),
              )),
    );
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
    return Row(
      children: <Widget>[
        Slider(
          activeColor: Colors.red[900],
          inactiveColor: Colors.white30,
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
        Text("${_dragValue ?? widget.position.inHours.toInt()}:${_dragValue ?? widget.position.inMinutes.toInt()}:${_dragValue ?? widget.position.inSeconds.toInt()}/${_dragValue ?? widget.duration.inHours.toInt()}:${_dragValue ?? widget.duration.inMinutes.toInt()}:${_dragValue ?? widget.duration.inSeconds.toInt()}",style: TextStyle(color: Colors.white,fontSize: 11.0),)
      ],
    );
  }
}
