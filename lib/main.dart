import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities/my_home.dart';
import 'globals.dart';


import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});
  const MyApp({Key? cle}) : super(key: cle);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      //initialRoute: '/',
      routes: {
        //'/': (context) => const MyHomePage(title: appName),
        '/myHome': (context) => const MyHome(),
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
  void initState() {
    super.initState();

    googleFontsPending = GoogleFonts.pendingFonts([
      GoogleFonts.poppins(),
      GoogleFonts.montserrat(fontStyle: FontStyle.italic),
    ]);
  }

  @override
  Widget build(BuildContext context) {

    final homeTextStyle = GoogleFonts.montserrat(
      fontSize: 24,
      color: Colors.purple,
      textStyle: Theme.of(context).textTheme.displayLarge,
    );

    final homeTextStyle2 = GoogleFonts.montserrat(
      fontSize: 20,
      color: Colors.purple,
      textStyle: Theme.of(context).textTheme.displayMedium,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: googleFontsPending,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox();
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/svg/undraw_pride.svg',
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(68,24,68,0),
                  child: Text(
                    "BIENVENUE sur l'app ADHEOS Rainbow!",
                    style: homeTextStyle,
                  ),
                ),
                const SizedBox(height: 20, width: 0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(68,0,68,20),
                  child: Text(
                    "Adhéos est une association LGBTI militante et conviviale accueille "
                        "informe et défend les droits des personnes LGBTI en France et dans le monde.",
                    style: homeTextStyle2,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      //Navigator.pushNamed(context, '/myHome');
                      Navigator.popAndPushNamed(context, "/myHome");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[500],
                      maximumSize: const Size(300, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                      //minimumSize: const Size(32, 32),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                      elevation: 8, // set the elevation to 8
                      shadowColor: Colors.black,
                    ),
                    child: const Center(
                      child: Text(
                        appName,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: Colors.purple[50],
    );
  }
}
