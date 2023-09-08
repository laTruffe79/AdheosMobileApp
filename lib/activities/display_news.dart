import 'package:flutter/material.dart';
//import 'dart:developer';
//import 'package:adheos/globals.dart';
import 'package:adheos/models/Article.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adheos/ui/my_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:io';

class DisplayNews extends StatefulWidget {

  final Article article;

  DisplayNews({
    Key? key,
    required this.article
  }) : super(key:key) ;

  @override
  State<DisplayNews> createState() => _DisplayNewsState(article);
}

enum SocialMedia{ facebook, X, whatsapp, linkedin }

class _DisplayNewsState extends State<DisplayNews> {

  List<dynamic> content = [];
  Article article;
  String description = "";
  double safeAreaSize = 0;

  _DisplayNewsState(this.article);

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<void> getWebsiteData(String url) async{

    final response = await http.get(Uri.parse(url));

    const String selector = 'div.entry-content > p';

    dom.Document html = dom.Document.html(response.body);

    content = html.querySelectorAll(selector)
        .map((element) => element.innerHtml.trim())
        .toList();

    for(final element in content){

      String addedText = parseFragment(element).text ?? "";
      description += "$addedText\n\n" ;

    }

  }

  Widget buildSocialButtons() => Card(

    elevation: 0,
    color: const Color.fromRGBO(22, 2, 45, 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSocialButton(
          icon: FontAwesomeIcons.squareShareNodes,
          color: const Color.fromRGBO(217, 42, 255, 1),
          onClicked: () => share(article.title,article.url)
        ),
      ],
    ),
  );

  Widget buildSocialButton({ required IconData icon,
    Color? color,
    required VoidCallback onClicked
  })
  => InkWell(
    onTap: onClicked,
    child: Container(
      width: 72,
      height: 72,
      child: Center(
        child: FaIcon(icon,color:color,size:52),
      ),
    ),
  );

  Future share(String subject, String urlShare) async{
    subject = Uri.encodeComponent(subject);
    final Uri uriShare = Uri.parse(urlShare);


    try {
      await Share.shareUri(uriShare);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error : $e.toString()")));
    }

  }

  @override
  Widget build(BuildContext context) {

    MyAppBar myAppBar = MyAppBar(
        title: "",
        icon: Icons.arrow_back,
        color: Theme.of(context).colorScheme.primary,
        routeName: "/myHome"
    );

    // get status bar height
    safeAreaSize = myAppBar.preferredSize.height;
    // add margin depending on platform
    Platform.isAndroid ? safeAreaSize += 25 : safeAreaSize += 65;


    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromRGBO(36, 6, 64, 1),
      appBar: myAppBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color.fromRGBO(36, 6, 64, 1), Color.fromRGBO(102, 34, 161, 1)],
          ),
        ),
        child: FutureBuilder(future: getWebsiteData(article.url),builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot ){
          return snapshot.connectionState == ConnectionState.waiting ?
          Center(
              child: Container(
                height: 200,
                width: 200,
                child: const CircularProgressIndicator(
                  color: Colors.purple,
                  strokeWidth: 10,
                ),
              )
          )
              : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24,vertical: safeAreaSize),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  Image.network(widget.article.imageUrl),
                  const SizedBox(height: 35),
                  Text( description,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  //SizedBox(height: 15)
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: buildSocialButtons()
    );
  }
}
