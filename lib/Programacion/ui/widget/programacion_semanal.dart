import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:radioklais/Programacion/ui/widget/ListaProgramas.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:radioklais/User/bloc/bloc_user.dart';

class ProgramacionSemanal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProgramacionSemanal();
  }
}

class _ProgramacionSemanal extends State<ProgramacionSemanal> {
  DateFormat dateFormat;
  DateFormat timeFormat;
  UserBloc userBloc;
  String dia_actual="";
  List lista=[];
  bool vacio=null;
  final availableLocalesForDateFormatting = const [
    "es",
    "es_419",
    "es_ES",
    "es_MX",
    "es_US",
  ];

  ScrollController _scrollController = ScrollController();

  _scrollToBottom(double volver) {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent-volver);
  }

  _getProgramasDiarios(String dia){
    setState(() {
      vacio=null;
      dia_actual=dia;
      lista=[{"mes":"asd"}];
    });
    var citiesRef = Firestore.instance.collection("programacion");
    citiesRef.where("dias",arrayContains: "${dia}").getDocuments().then((querySnapshot) {
      if (querySnapshot.documents.length>0){
        setState(() {
          vacio=null;
          dia_actual=dia;
          lista=[];
        });
        querySnapshot.documents.forEach((result) {
          setState(() {
          vacio=false;
            lista.add(result.data);
          });
          print(lista.length);
        });
      }else{
        setState(() {
          vacio=true;
        });
      }
    });
  }
  @override
  void initState() {
    initializeDateFormatting();
    dateFormat = new DateFormat.EEEE('es_ES');
    print(dateFormat.format(DateTime.now()));
    setState(() {
      vacio=null;
      dia_actual=dateFormat.format(DateTime.now());
    });
    // TODO: implement initState
    var citiesRef = Firestore.instance.collection("programacion");
    citiesRef.where("dias",arrayContains: "${dateFormat.format(DateTime.now())}").getDocuments().then((querySnapshot) {
      setState(() {
        vacio=null;
        lista=[];
      });
      if (querySnapshot.documents.length>0){
        setState(() {
          vacio=null;
          dia_actual=dateFormat.format(DateTime.now());
          lista=[];
        });
        querySnapshot.documents.forEach((result) {
          setState(() {
            vacio=false;
            lista.add(result.data);
          });
          print(lista.length);
        });
      }else{
        setState(() {
          lista=[];
          vacio=true;
        });
      }

    });
    super.initState();

  }

  Widget DiaSemana(String dia){
    return   Container(
      margin: EdgeInsets.only(right: 12.0),
      child: DecoratedBox(
        decoration: ShapeDecoration(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: dia_actual == dia.toLowerCase() ?Colors.red:Colors.black87),
        child: Theme(
          data: Theme.of(context).copyWith(
              buttonTheme: ButtonTheme.of(context).copyWith(
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap)),
          child: OutlineButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            child: Text(
              '${dia}',
              style: TextStyle(
                  color: Colors.white70, fontFamily: "ubuntu"),
            ),
            onPressed: () => {
              _getProgramasDiarios("${dia.toLowerCase()}")
            },
          ),
        ),
      ),
    );
  }

  @override

  Widget build(BuildContext context) {

    var dateTime = new DateTime.now();
    userBloc = BlocProvider.of<UserBloc>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if(dia_actual=="jueves"){
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(100.0));
    }
    if(dia_actual=="viernes" || dia_actual=="sábado" || dia_actual=="domingo" ){
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(0.0));
    }
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.black87,
          height: height,
          width: width,
          child: Column(
            children: <Widget>[
              Container(
                height: 60.0,
                width: width,
                child: Center(
                  child: Container(
                    width: width,
                    height: 36,
                    child: ListView(
                      padding: EdgeInsets.only(left: 30.0,right: 30.0),
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      children: <Widget>[
                        DiaSemana("Lunes"),
                        DiaSemana("Martes"),
                        DiaSemana("Miércoles"),
                        DiaSemana("Jueves"),
                        DiaSemana("Viernes"),
                        DiaSemana("Sábado"),
                        DiaSemana("Domingo"),
                      ],
                    ),
                  ),
                ),
              ),
              new Container(
                  height: height-295,
                  child: new ListView.builder
                    (
                      shrinkWrap: true,
                      itemCount: lista.length,
                      addRepaintBoundaries: true,
                      addAutomaticKeepAlives: true,
                      addSemanticIndexes: true,
                      scrollDirection: Axis.vertical,

                      itemBuilder: (BuildContext ctxt, int index) {
                        return vacio == false ? GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ListaProgramas([lista[index]])),
                              );
                            },
                            child: Container(

                              padding: EdgeInsets.only(top: 10.0),
                              child: Container(
                                  padding: EdgeInsets.only(right: 36.0,left: 36.0,bottom: 10.0),
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding:EdgeInsets.only(bottom: 8.0),
                                        child: Text('${lista[index]['titulo']}',style: TextStyle(fontFamily: "Ubuntu",fontSize: 18.0,color:Colors.white70),),
                                      ),
                                      Image(
                                        width: 400,
                                        image: NetworkImage("${lista[index]['foto']}"),
                                      ),
                                      Container(
                                        padding:EdgeInsets.only(top: 8.0),
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text('${lista[index]['horario']}',style: TextStyle(fontFamily: "Ubuntu",fontSize: 15.0,color:Colors.white30),)
                                          ],
                                        ),
                                      ),


                                    ],
                                  )

                              ),
                            )): vacio == null ? Container(
                          width: width,
                          padding: EdgeInsets.only(bottom: 40.0),
                          child: Center(
                            child: Container(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ): Container(
                            width: width,
                            height: 300.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.broken_image,size: 50.0,color: Colors.white70,),
                                Text("Programamción pendiente",style: TextStyle(fontFamily: "Ubuntu",fontSize: 18.0,color:Colors.white70),)
                              ],
                            )
                        );
                      }
                  )),
            ],
          ),
        )
      ],
    );
  }



}
