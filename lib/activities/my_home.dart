import 'package:adheos/globals.dart';
import 'package:flutter/material.dart';

//import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import 'dart:convert';
import 'package:html/parser.dart';
import 'display_news.dart';
import 'package:adheos/models/Article.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter/services.dart';
import 'package:adheos/ui/menu.dart' as MyNavigationDrawer;
import 'package:page_transition/page_transition.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  //String rssUri = "https://developer.apple.com/news/releases/rss/releases.rss";
  String firstTitle = "";
  final Xml2Json xml2json = Xml2Json();
  List items = [];
  Global global = Global.instance;

  Future<String> getRss() async {
    final Uri url = Uri.parse(rssUri);
    final http.Response response = await http.get(url);

    xml2json.parse(response.body.toString());
    String jsonData = xml2json.toGData();

    return jsonData;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchAndPrintRss() async {
    if (global.mainAppItems.isEmpty) {
      String rssData = await getRss(); // Await the result
      var data = json.decode(rssData);
      items = data['rss']['channel']['item'];
      global.mainAppItems = items;
    } else {
      items = global.mainAppItems;
    }
  }

  Future<void> _handleRefresh() async {
    global.mainAppItems = [];
    return await fetchAndPrintRss();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        )
    );

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(27, 33, 78, 1.0),
        drawer: MyNavigationDrawer.NavigationDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          forceMaterialTransparency: true,
          centerTitle: true,
          title: const Text(
            "News Adhéos",
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromRGBO(36, 6, 64, 1),
                Color.fromRGBO(102, 34, 161, 1)
              ],
            ),
          ),
          child: LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            animSpeedFactor: 3,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.purple.shade100,
            height: 200,
            showChildOpacityTransition: true,
            child: FutureBuilder(
                future: fetchAndPrintRss(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? Center(
                          child: Container(
                          height: 200,
                          width: 200,
                          child: const CircularProgressIndicator(
                            color: Colors.purple,
                            strokeWidth: 10,
                          ),
                        ))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: items.length,
                                  itemBuilder: itemBuilder),
                            ],
                          ),
                        );
                }),
          ),
        ));
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items[index];

    String title =
        parseFragment(json.encode(item['title']['\$t'])).text ?? "pas de titre";
    String description =
        parseFragment(json.encode(item['description']['__cdata'])).text ??
            "pas de description";
    String imageUrl = item['imageUrl']['\$t'].toString();
    String link = item['link']['\$t'].toString();

    Article article = Article(title, imageUrl, description, link);
    //print("article : $article.toString()");
    return GestureDetector(
      onTap: () {
        //Navigator.pop(context);
        Navigator.push(
          context,
          /*MaterialPageRoute(
            builder: (context) => DisplayNews(
              key: Key("news $index.toString()"),
              article: article,
            ),
          ),*/
          PageTransition(
              child: DisplayNews(
                key: Key("news $index.toString()"),
                article: article,
              ),
              type: PageTransitionType.rightToLeft,
              isIos: true,
          )
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Add an image widget to display an image
          Container(
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 0),
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(22, 2, 45, 1),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(0), bottom: Radius.circular(10))),
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
