
class Article{

  String _title;
  String _datePub;
  String _imageUrl;
  String _description;
  String _url;


  Article(this._title, this._imageUrl, this._description, this._url,this._datePub);

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get imageUrl => _imageUrl;

  set imageUrl(String value) {
    _imageUrl = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get datePub => _datePub;

  set datePub(String value) {
    _datePub = value;
  }

  @override
  String toString() {
    return 'Article{_title: $_title, _imageUrl: $_imageUrl, _description: $_description, _url: $_url}';
  }
}