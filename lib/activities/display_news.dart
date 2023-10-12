import 'package:flutter/material.dart';

//import 'dart:developer';
import 'package:adheos/models/Article.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adheos/ui/my_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adheos/globals.dart';
import 'dart:math';

//import 'package:flutter/foundation.dart';
//import 'package:page_transition/page_transition.dart';
import 'dart:io';

class DisplayNews extends StatefulWidget {
  final Article? article;
  final bool isEvent;

  const DisplayNews({
    Key? key,
    Article? this.article,
    bool this.isEvent = false,
  }) : super(key: key);

  @override
  State<DisplayNews> createState() =>
      _DisplayNewsState(article: article, isEvent: this.isEvent);
}

class _DisplayNewsState extends State<DisplayNews> {
  List<dynamic> content = [];
  Article? article;
  String description = "";
  double safeAreaSize = 0;
  bool _isEvent = false;

  _DisplayNewsState({Article? article, bool isEvent = false}) {
    this.article = article;
    this._isEvent = isEvent;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getWebsiteData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      switch (response.statusCode) {
        case 200:
          String selector = this._isEvent
              ? 'div.tribe-events-single-event-description.tribe-events-content'
              : 'div.entry-content > p';

          dom.Document html = dom.Document.html(response.body);

          content = html
              .querySelectorAll(selector)
              .map((element) => element.innerHtml.trim())
              .toList();

          for (final element in content) {
            String addedText = parseFragment(element).text ?? "";
            description += "$addedText\n\n";
          }

        default:
          throw Exception(response.reasonPhrase);
      }
    } on Exception catch (e) {
      SnackBar(content: Text("Erreur : $e.toString()"));
      rethrow;
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
                icon: this._isEvent
                    ? Icons.email
                    : FontAwesomeIcons.squareShareNodes,
                color: const Color.fromRGBO(217, 42, 255, 1),
                onClicked: this._isEvent
                    ? () {
                        String? encodeQueryParameters(
                            Map<String, String> params) {
                          return params.entries
                              .map((e) =>
                                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                              .join('&');
                        }

                        //
                        final Uri subscribeByEmail = Uri(
                            scheme: 'mailto',
                            path: emailSubscribeEvents,
                            query: encodeQueryParameters(<String, String>{
                              'subject':
                                  'Je souhaite participer à l\'évènement ${article?.title}',
                              'body':
                                  'Prénom, nom souhaite participer à l\'évènement ${article?.title} qui aura lieu le ${article?.datePub}'
                            }));

                        try {
                          launchUrl(subscribeByEmail);
                        } on Exception catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("Error : $e.toString()")));
                        }
                      }
                    : () => share(article?.title ?? "", article?.url ?? "")),
          ],
        ),
      );

  Widget buildSocialButton(
          {required IconData icon,
          Color? color,
          required VoidCallback onClicked}) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          alignment: Alignment.centerRight,
          width: 35,
          height: double.infinity,
          child: FaIcon(icon, color: color, size: 30),
        ),
      );

  Future share(String subject, String urlShare) async {
    subject = Uri.encodeComponent(subject);
    final Uri uriShare = Uri.parse(urlShare);

    try {
      await Share.shareUri(uriShare);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error : $e.toString()")));
    }
  }

  @override
  Widget build(BuildContext context) {
    MyAppBar myAppBar = MyAppBar(
        title: "",
        icon: Icons.arrow_back,
        color: Theme.of(context).colorScheme.primary,
        routeName: _isEvent ? "/events" : "/myHome");

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
              colors: [
                Color.fromRGBO(36, 6, 64, 1),
                Color.fromRGBO(102, 34, 161, 1)
              ],
            ),
          ),
          child: FutureBuilder(
              future: getWebsiteData(article?.url ?? ""),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: safeAreaSize),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                color: const Color.fromRGBO(22, 2, 45, 0.6),
                                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                                child: ListTile(
                                  leading: Icon(
                                    this._isEvent
                                        ? FontAwesomeIcons.calendarDays
                                        : FontAwesomeIcons.newspaper,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    this._isEvent ? "Rendez-vous le ${article?.datePub}" : "${article?.datePub}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: buildSocialButton(
                                    icon: this._isEvent
                                        ? Icons.email
                                        : FontAwesomeIcons.squareShareNodes,
                                    color: const Color.fromRGBO(217, 42, 255, 1),

                                    onClicked: this._isEvent
                                        ? () {
                                      String? encodeQueryParameters(
                                          Map<String, String> params) {
                                        return params.entries
                                            .map((e) =>
                                        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                            .join('&');
                                      }

                                      //
                                      final Uri subscribeByEmail = Uri(
                                          scheme: 'mailto',
                                          path: emailSubscribeEvents,
                                          query: encodeQueryParameters(<String, String>{
                                            'subject':
                                            'Je souhaite participer à l\'évènement ${article?.title}',
                                            'body':
                                            'Prénom, nom souhaite participer à l\'évènement ${article?.title} qui aura lieu le ${article?.datePub}'
                                          }));

                                      try {
                                        launchUrl(subscribeByEmail);
                                      } on Exception catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text("Error : $e.toString()")));
                                      }
                                    }
                                        : () => share(article?.title ?? "", article?.url ?? ""),

                                  ),
                                  contentPadding: const EdgeInsets.all(0),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Text(
                                '${article?.title ?? ""}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              /*FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholders/${Random().nextInt(4)+1}.jpg',
                                  image: article?.imageUrl ?? "",
                              ),*/
                              Image.network(
                                  widget.article?.imageUrl ?? "",
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/placeholders/${Random().nextInt(4)+1}.jpeg',);
                                  },
                              ),
                              const SizedBox(height: 35),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 17,
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
        //bottomNavigationBar: buildSocialButtons()
    );
  }
}
