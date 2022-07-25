import 'package:good_point_client/models/Point.dart';
import 'package:good_point_client/models/User.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final Point point;
  final String commentText;
  final User author;

  Comment(this.id, this.point, this.commentText, this.author);

  factory Comment.fromJson(Map<String, dynamic> json)
    => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}