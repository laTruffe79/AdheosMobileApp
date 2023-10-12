const String appName = 'Adhéos Rainbow';
const String rssUri = "https://www.adheos.org/feed/";
const String rssEvents = "https://www.adheos.org/evenements/feed/";

const String emailSubscribeEvents = 'contact@adheos.org';


class Global{

  List mainAppItems = [];
  List mainAppEvents = [];

  String? appVersion = null;

  Global._();

  static final instance = Global._();

}

