import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities/my_home.dart';
import 'globals.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'ui/style/text_styles.dart';
// firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:adheos/firebase_options.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:adheos/api/firebase_api.dart';
import 'dart:async';

final navigatorState = GlobalKey<NavigatorState>();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseApi().initNotifications();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));


}

class MyApp extends StatelessWidget {
  const MyApp({Key? cle}) : super(key: cle);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light, // 2
        ),
      ),
      //initialRoute: '/',
      navigatorKey: navigatorState,
      routes: {
        //'/': (context) => const MyHomePage(title: appName),
        '/myHome': (context) => const MyHome(),
        '/events': (context) => const MyHome(key: ValueKey('events'), displayNewsList: false)

      },

      home: const MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future googleFontsPending;

  @override
  void initState(){
    super.initState();

    googleFontsPending = GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.montserrat(fontStyle: FontStyle.italic),
    ]);

    startTimer();
  }

  startTimer(){
    Duration duration = const Duration(seconds: 7);
    return Timer(duration, () {
      Navigator.popAndPushNamed(context, "/events");
    });

  }

  @override
  Widget build(BuildContext context) {

    final homeTextStyle = GoogleFonts.montserrat(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      textStyle: Theme.of(context).textTheme.displayLarge,
    );

    final homeTextStyle2 = GoogleFonts.montserrat(
      fontSize: 17,
      height: 1.4,
      color: Colors.white,
      textStyle: Theme.of(context).textTheme.displayMedium,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
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
        child: Center(
          child: FutureBuilder(
            future: googleFontsPending,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(46, 70, 46, 0),
                        child: Image.asset(
                          'assets/Logo.gif',
                          width: 420,
                          height: 420,
                          fit: BoxFit.fill,
                          repeat: ImageRepeat.noRepeat,
                        ),
                      ),
                  ),
                  Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(54, 30, 54, 0),
                            child: Text(
                              "BIENVENUE sur l'app ADHEOS Rainbow!",
                              style: homeTextStyle,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 10, width: 0),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(54, 0, 54, 20),
                            child: Text(
                              "Adhéos est une association LGBTI militante et conviviale accueille "
                                  "informe et défend les droits des personnes LGBTI en France et dans le monde.",
                              style: homeTextStyle2,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      )
                  )

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
