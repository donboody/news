import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';

import 'news_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = 'https://newsapi.org/v2/top-headlines?' +
      'country=us&' +
      'apiKey=e1b356f178584c24b2d43985071406b0';

  int totalResults;
  List data;

  bool isSearching = false;

  final textCtrl = TextEditingController();
  String searchString = "";

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    isSearching == false ? makeRequest(url) : updateList(searchString);
  }

  void updateList(String searchTerm) {
    if (searchTerm == null || searchTerm == "") {
      makeRequest(url);
    }
    var customUrl = 'https://newsapi.org/v2/everything?' +
        'q="$searchTerm"&' +
        'from=2019-03-05&' +
        'sortBy=popularity&' +
        'language=en&' +
        'apiKey=e1b356f178584c24b2d43985071406b0';

    makeRequest(customUrl);
  }

  Future<String> makeRequest(url) async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    setState(() {
      var extractData = json.decode(response.body);
      totalResults = extractData["totalResults"];
      data = extractData["articles"];
    });

    print(response.body);
    print(totalResults);

    return null;
  }

  _launchNewsApiSite() async {
    const url = 'https://newsapi.org/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> infoDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'NewsBoi was developed in Flutter using the free NewsAPI. Free NewsAPI requests limited to 1000 per day (total amongst all users). NewsBoi is free and generates no revenue for the developer. NewsBoi exists for demonstration and educational purposes only.'),
            actions: <Widget>[
              FlatButton(
                child: Text('NewsAPI'),
                onPressed: _launchNewsApiSite,
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            infoDialog(context).then((value) {
              print('Value is $value');
            });
          },
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(isSearching == false ? Icons.search : Icons.clear),
            onPressed: () {
              setState(() {
                searchString = "";
                textCtrl.text = searchString;
                isSearching = !isSearching;
                if (isSearching == false) {
                  makeRequest(url);
                }
              });
            },
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: isSearching == false
            ? Text(
                'NewsBoi',
                style: TextStyle(
                  color: Colors.black,
                ),
              )
            : TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hintText: 'SearchBoi',
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    )),
                onChanged: (String textInput) {
                  setState(() {
                    searchString = textCtrl.text.toString();
                  });
                },
                onEditingComplete: () {
                  updateList(searchString);
                  _focusNode.unfocus();
                },
                controller: textCtrl,
                focusNode: _focusNode,
              ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () async {
          isSearching == false ? makeRequest(url) : updateList(searchString);
        },
        child: totalResults == 0
            ? Center(
                child:
                    Text('No articles found for search term: "$searchString"'),
              )
            : ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, i) {
                  return NewsCard(
                    source: data[i]["source"]["name"],
                    title: data[i]["title"],
                    subtitle: data[i]["author"] == null
                        ? data[i]["source"]["name"]
                        : data[i]["author"],
                    networkImageUrl: data[i]["urlToImage"] == null
                        ? ""
                        : data[i]["urlToImage"],
                    articleUrl: data[i]["url"],
                  );
                },
              ),
      ),
    );
  }
}
