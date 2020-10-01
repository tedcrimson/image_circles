import 'package:image_circles/models/firebase_model.dart';
import 'package:image_circles/models/question.dart';

class Level extends FirebaseModel {
  Level.fromJson(dynamic data) : super.fromJson(data) {
    questions = [];
    for (var item in data['collection']) {
      questions.add(Question.fromJson(item));
    }
  }

  List<Question> questions;
}
