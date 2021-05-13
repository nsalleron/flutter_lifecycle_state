import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: ApplicationLifeCycle(),
    );
  }
}

class ApplicationLifeCycle extends StatefulWidget {
  const ApplicationLifeCycle({Key? key}) : super(key: key);

  @override
  _ApplicationLifeCycleState createState() => _ApplicationLifeCycleState();
}

class _ApplicationLifeCycleState extends State<ApplicationLifeCycle> with WidgetsBindingObserver {
  late Future<Cat> cat;


  @override
  void initState() {
    super.initState();
    cat = _fetchData();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      if(state == AppLifecycleState.resumed ){
        print("resumed");
        cat = _fetchData();
      }else if (state == AppLifecycleState.detached){
        print("detached");
      }else if (state == AppLifecycleState.inactive){
        print("inactive");
      }else if (state == AppLifecycleState.paused){
        print("paused");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple lifecycle refresh",
            style: TextStyle(fontFamily: 'Roboto')),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<Cat>(
                future: cat,
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    return Image.network(snapshot.data!.imageUrl, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.8,);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            ElevatedButton(onPressed: (){
              setState(() {
                cat = _fetchData();
              });
            }, child: Text('new cat !'))
          ],
        ),
      ),
    );
  }

  Future<Cat> _fetchData() async {
    var url = Uri.parse('https://api.thecatapi.com/v1/images/search?');
    print('fetching new cat...');
    final response = await http.get(url);

    if(response.statusCode == 200){
      print('done!');
      return Cat.fromJSON(jsonDecode(response.body)[0]);
    }else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load my cat :(');
    }

  }
}

class Cat {
  final String imageUrl;
  final String id;

  Cat.fromJSON(Map<String, dynamic> json) : id = json['id'], imageUrl = json['url'];
}
