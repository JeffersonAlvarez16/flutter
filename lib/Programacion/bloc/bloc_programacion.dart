import 'dart:async';

import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:just_audio/just_audio.dart';

class ProgramacionBloc implements Bloc {
  //registrar datos reproductor

  final _text$ = StreamController<String>();
  Stream<String> get text$ => _text$.stream;
  Sink<String> get text => _text$.sink;

  final _player$ = StreamController<AudioPlayer>();
  Stream<AudioPlayer> get player$ => _player$.stream;
  Sink<AudioPlayer> get player => _player$.sink;
  @override
  void dispose() {
    _text$.close();
    _player$.close();
  }
}
