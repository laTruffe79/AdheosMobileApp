import 'package:adheos/globals.dart';
import 'package:flutter/material.dart';

import 'dart:io';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

class MyHome extends StatefulWidget {
  const MyHome({Key? key, this.displayNewsList = true}) : super(key: key);

  final bool displayNewsList;

  @override
  State<MyHome> createState() => _MyHomeState(displayNewsList: this.displayNewsList);
}

class _MyHomeState extends State<MyHome> with WidgetsBindingObserver {
  //String rssUri = "https://developer.apple.com/news/releases/rss/releases.rss";
  String firstTitle = "";
  Xml2Json xml2json = Xml2Json();
  List items = [];
  Global global = Global.instance;
  // if false display events
  bool _displayNewsList;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );


  _MyHomeState({required displayNewsList}) : _displayNewsList = displayNewsList;

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }


  Future<String> getRss(String uri ) async {

    final Uri url = Uri.parse(uri);
    String jsonData = "";

    try{
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        //String? responseBody = response.body.toString();
        xml2json.parse(response.body.toString());
        jsonData = xml2json.toGData();
      }

    } on SocketException catch(_){
      const SnackBar(
          content: Text("Oops ! Pas de connexion internet ?..."),
      );
    }

    return jsonData;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initPackageInfo().then((_) => global.appVersion = _packageInfo.version);

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle states in order to refresh data on resumed state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){

      setState(() {
        global.mainAppItems = [];
        items = [];
      });

    }
  }

  Future<void> fetchAndPrintRss() async {

    List _collection = this._displayNewsList ? global.mainAppItems : global.mainAppEvents;

    if (_collection.isEmpty) {

      String rssData = await getRss(this._displayNewsList ? rssUri : rssEvents); // Await the result
      var data = json.decode(rssData);
      items = data['rss']['channel']['item'];
      _collection = items;
      this._displayNewsList ? global.mainAppItems = _collection : global.mainAppEvents = _collection;
    } else {
      items = _collection;
    }
  }

  // refresh
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


    if(Platform.isAndroid){
      return WillPopScope(
          onWillPop: () async {

            if(this._displayNewsList){
              Navigator.pop(context);
              return false;
            }else{
              return true;
            }

          },
          child: myHomeScaffold(),
      );
    }
    return myHomeScaffold();


  }

  Widget myHomeScaffold(){
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color.fromRGBO(27, 33, 78, 1.0),
        endDrawer: ModalRoute.of(context)?.settings.name == '/events'? const MyNavigationDrawer.NavigationDrawer() : null,
        appBar: AppBar(
          //leading: Image.asset('assets/adheos_logo_1024.png'),
          iconTheme: const IconThemeData(color: Colors.white),
          forceMaterialTransparency: true,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/adheos_logo_1024.png',width: 25,height: 25,),
              const SizedBox(width: 10),
              Text(
                this._displayNewsList ? "News Adhéos" : "Rendez-vous Adhéos",
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ],
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

    String title = parseFragment(json.encode(item['title']['\$t'])).text ?? "pas de titre";
    String description = parseFragment(json.encode(item['description']['__cdata'])).text ??  "pas de description";

    String imageUrl = item['image']['url']['\$t'].toString();
    String link = item['link']['\$t'].toString();
    // @todo add try catch FormatException

    var dateNode = item['pubDate']['\$t'].toString();
    DateTime dt = DateTime.parse(dateNode);
    String datePub = '${dt.day.toString()}-${dt.month.toString()}-${dt.year.toString()}';

    Article article = Article(title, imageUrl, description, link, datePub);
    //print("article : $article.toString()");
    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          PageTransition(
              child: DisplayNews(
                key: Key("news $index.toString()"),
                article: article,
                isEvent: this._displayNewsList ? false : true,
              ),
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 600) ,
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
                      top: Radius.circular(10),
                      bottom: Radius.circular(10),
                  )
              ),

              margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      alignment: Alignment.topLeft,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5,0,0,0),
                        child:
                        ListTile(
                          leading:  Icon(this._displayNewsList ? FontAwesomeIcons.newspaper : FontAwesomeIcons.calendarDays,color: Colors.white,),
                          title: Text(this._displayNewsList ? article.datePub : "Rendez-vous le ${article.datePub}" ,style: const TextStyle(color: Colors.white),),
                          contentPadding: const EdgeInsets.fromLTRB(10,0,0,0),
                        ),
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Stack(
                      fit: StackFit.loose,
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          height: 250,
                          alignment: Alignment.center,
                          child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(10)
                              ),
                              child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.pinkAccent.shade400.withOpacity(0.6) , colorBlendMode: BlendMode.xor,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholders/${Random().nextInt(4)+1}.jpeg',
                                  height: double.infinity,
                                  width: double.infinity,
                                  color: Colors.pinkAccent.shade400.withOpacity(0.6) , colorBlendMode: BlendMode.xor,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          )
                        ),
                        Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '$title',
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
                      ],
                    ),
                  ),

                ],
              ))
        ],
      ),
    );
  }
}
