import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ref/firestore_ref.dart';
import 'package:meta/meta.dart';

typedef DocumentDecoder<D extends Document<dynamic>> = D Function(
    DocumentSnapshot snapshot);

typedef EntityEncoder<E> = Map<String, dynamic> Function(
  E entity,
);

@immutable
class Document<E> {
  const Document(
    this.id,
    this.entity,
  );

  final String id;
  final E entity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          entity == other.entity;

  @override
  int get hashCode => id.hashCode ^ entity.hashCode;
}
