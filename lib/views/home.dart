import 'dart:convert';
import 'package:transparent_image/transparent_image.dart';
import 'package:app_buscador_gifs/views/gifPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offSet = 0;


  Future<Map> _getSearch() async{
    http.Response response;

    if(_search == null || _search.isEmpty){
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=PzNsGUKsadfich4URSlKmCd6JIUukcSh&limit=20&rating=g"));
    }else{
      response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/search?api_key=PzNsGUKsadfich4URSlKmCd6JIUukcSh&q=$_search&limit=19&offset=$_offSet&rating=g&lang=pt"));
    }
    return json.decode(response.body);
  }

  @override
  void initState(){
    super.initState();

    _getSearch().then((map){
      print(map);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui!",
                labelStyle: TextStyle(
                  color: Colors.white
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    )),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState((){
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getSearch(),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return _createGifTable(context, snapshot);
                    }else{
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    }
                  }
              )
          ),
        ],
      )
    );
  }
  
  int _getCount(List data){
    if(_search == null){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index){
          if(_search == null || index < snapshot.data['data'].length){
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data['data'][index]['images']['fixed_height']['url'],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => gifPage(snapshot.data['data'][index])));
              },
            );
          }else{
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text("Carregar mais...", style: TextStyle(color: Colors.white, fontSize: 22.0))
                  ],
                ),
                onTap: (){
                  setState((){
                    _offSet += 19;
                  });
                },
                onLongPress: (){
                  Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
                },
              ),
            );
          }
      }
    );
  }
}
