import 'package:good_point_client/models/Comment.dart';
import 'package:json_annotation/json_annotation.dart';
import 'Category.dart';

part 'Point.g.dart';

@JsonSerializable(explicitToJson: true)
class Point {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final Category category;

  @JsonKey(defaultValue: "")
  final String story;

  @JsonKey(defaultValue: [])
  final List<Comment> comments;

  Point(
      this.title,
      this.description,
      this.latitude,
      this.longitude,
      this.category,
      this.story,
      this.comments
      );

  Point.fromCoordinates(this.latitude, this.longitude) :
        title = "mock",
        description = "description",
        category = Category.SIGHT,
        story = "story",
        comments = List.empty();

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);
}
