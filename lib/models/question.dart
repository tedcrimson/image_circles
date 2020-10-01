import 'package:image_circles/models/firebase_model.dart';

class Question extends FirebaseModel {
  String answer;
  String url;

  Question.fromJson(dynamic data) : super.fromJson(data) {
    answer = data['answer'];
    url = data['url'];
  }
}
