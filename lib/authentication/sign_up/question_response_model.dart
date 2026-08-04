class QuestionResponseModel {
  QuestionResponseModel({String? id, String? question}) {
    _id = id;
    _question = question;
  }

  QuestionResponseModel.fromJson(dynamic json) {
    _id = json['id'];
    _question = json['question'];
  }

  String? _id;
  String? _question;

  QuestionResponseModel copyWith({String? id, String? question}) =>
      QuestionResponseModel(id: id ?? _id, question: question ?? _question);

  String? get id => _id;

  String? get question => _question;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['question'] = _question;
    return map;
  }
}
