import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response_model.g.dart';

/// Login/Register response model
@JsonSerializable()
class LoginResponseModel {
  @JsonKey(name: 'access_token')
  final String token;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  final UserModel user;

  LoginResponseModel({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
