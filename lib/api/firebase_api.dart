import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:adheos/main.dart';
import 'package:url_launcher/url_launcher.dart';

class FirebaseApi {

  final _firebaseMessaging = FirebaseMessaging.instance;
  bool permissionsGranted = false;

  Future<void> initNotifications() async{

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        announcement: true
    );

    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token : $fcmToken");
    // eQcusV6YSUyayPDyxlP4BU:APA91bGvxRqz_5bumEfG6TaeNHnQn5_dl0xkO4bFyPn73geWAu4hI61hgfZNn0W2w3x-W1-Jdkd6kG3GjHmqXD8O3vCC2k0R89blqzBVtrhokIa_Yl1eUi4DtgKWTjzwgLkkJlIQjd7b

    _firebaseMessaging.subscribeToTopic("news");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      permissionsGranted = true;
      print('permissions granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      log("User declined or has not accepted permission");
    }

    initBackgroundNotifications();

  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage? message) async {
    print('Title : ${message?.notification?.title}');
    print('body : ${message?.notification?.body}');
    print('payload : ${message?.data}');

    if (message != null) {

      print(message.toString());

      Map<String,dynamic> data = message.data;

      if (data.containsKey('type') && data['type'] == 'screen') {
        if (data.containsKey('route') && data['route'] != '') {

          navigatorState.currentState?.pushNamed(data['route']);

        }
      }else if(data.containsKey('type') && data['type'] == 'url'){

        if (data.containsKey('route') && data['route'] != '') {

          String routeValue = data['route'];
          launchUrl(Uri.parse("https://www.adheos.org/$routeValue"));
          //https://www.adheos.org/don
        }

      }else{

        navigatorState.currentState?.pushNamed('/myHome');

      }

    }

  }

  Future initBackgroundNotifications() async{

      _firebaseMessaging.getInitialMessage().then(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessageOpenedApp.listen(firebaseMessagingBackgroundHandler);
  }

}

