import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:adheos/globals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:adheos/activities/my_home.dart';

class NavigationDrawer extends StatelessWidget {

  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(

        child:  Container(
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //buildHeader(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/adheos_logo_1024.png',width: 60,height: 60,),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    buildMenuItems(context),
                  ],
                ),
              ),
            )
        )
    );
  }

  //Widget buildHeader(BuildContext context) => Container();

  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      runSpacing: 8,
      children: [
        ListTile(
            leading: const Icon(Icons.group,color: Colors.white,),
            title: const Text('Association LGBTI',style: TextStyle(color: Colors.white),),
            onTap: () {
              // close navigation drawer
              //Navigator.pop(context);
              Navigator.pop(context);
              launchUrl(Uri.parse("https://www.adheos.org"));
            }
        ),ListTile(
            leading: const Icon(Icons.question_answer_outlined,color: Colors.white,),
            title: const Text('Qui sommes-nous ?',style: TextStyle(color: Colors.white),),
            onTap: () {
              // close navigation drawer
              //Navigator.pop(context);
              Navigator.pop(context);
              launchUrl(Uri.parse("https://www.adheos.org/presentation"));
            }
        ),ListTile(
            leading: const Icon(Icons.euro,color: Colors.white,),
            title: const Text('Faire un don',style: TextStyle(color: Colors.white),),
            onTap: () {
              // close navigation drawer
              //Navigator.pop(context);
              Navigator.pop(context);
              launchUrl(Uri.parse("https://www.adheos.org/don"));
            }
        )
        ,GestureDetector(
          onTap : (){
            // close navigation drawer
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                  child: MyHome(
                      key: Key('displayNews'),
                      displayNewsList: true
                  ),
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 600) ,
                  isIos: true,
                )
            );
          },
          child: ListTile(
              leading: const Icon(FontAwesomeIcons.newspaper,color: Colors.white,),
              title: const Text(
                'News',
                style: TextStyle(color: Colors.white),
              ),
          ),
        ),
        ListTile(
            leading: const Icon(Icons.calendar_month,color: Colors.white,),
            title: const Text('Agenda/Évènements',style: TextStyle(color: Colors.white),),
            onTap: () {
              // close navigation drawer
              Navigator.pop(context);
              if( ModalRoute.of(context)?.settings.name != '/events') {

                Navigator.pushNamed(context, '/events');

              }

            }
        ),
        ListTile(
            leading:  const Icon(FontAwesomeIcons.discord,color: Colors.white,),
            title: const Text('Discord Adhéos',style: TextStyle(color: Colors.white),),
            onTap: () {
              // close navigation drawer
              //Navigator.pop(context);
              Navigator.pop(context);
              launchUrl(Uri.parse("https://discord.gg/avNCXrGYp8"));
            }
        ),
        ListTile(
          leading: const Icon(Icons.accessibility,color: Colors.white,),
          title: const Text('Contact',style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            launchUrl(Uri.parse("https://www.adheos.org/contact"));
          } ,
        ),
        ListTile(
            leading: const Icon(Icons.balance,color: Colors.white,),
            title: const Text('Mentions légales',style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              launchUrl(Uri.parse("https://www.adheos.org/mentions-legales"));
            }
        ),
        ListTile(
          //leading: const Icon(Icons.balance,color: Colors.white,),
          title: Text(
            'Version ${Global.instance.appVersion}',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
