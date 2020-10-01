import 'package:image_circles/models/firebase_model.dart';
import 'package:image_circles/models/level.dart';

class Logos extends FirebaseModel {
  Logos.fromJson(dynamic data) : super.fromJson(data) {
    levels = [];
    for (var item in data['levels']) {
      levels.add(Level.fromJson(item));
    }
  }

  List<Level> levels;
}
