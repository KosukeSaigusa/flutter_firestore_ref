import 'package:firestore_ref/firestore_ref.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @required int count,
    @timestampJsonKey DateTime createdAt,
    @timestampJsonKey DateTime updatedAt,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

class UsersRef extends CollectionRef<User, Document<User>> {
  UsersRef.ref()
      : super(
          ref: Firestore.instance.collection(collection),
          decoder: (snap) => Document<User>(
            snap.documentID,
            User.fromJson(snap.data),
          ),
          encoder: (entity) => replacingTimestamp(
            json: entity.toJson(),
            createdAt: entity.createdAt,
          ),
        );

  static const collection = 'users';
}
