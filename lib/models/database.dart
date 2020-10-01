import 'package:image_circles/models/firebase_model.dart';

import 'logos.dart';

class Database extends FirebaseModel {
  Database.fromJson(dynamic data) : super.fromJson(data) {
    logos = Logos.fromJson(data['logos']);
  }

  Logos logos;
}
