import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ref/firestore_ref.dart';
import 'package:meta/meta.dart';

import 'utils.dart';

@immutable
class DocumentRef<E, D extends Document<E>> {
  DocumentRef({
    @required String id,
    @required this.collectionRef,
  }) : ref = collectionRef.ref.document(id);

  final CollectionRef<E, D> collectionRef;
  final DocumentReference ref;

  Stream<D> document() {
    return ref.snapshots().map((snapshot) {
      if (recordFirestoreOperationCount) {
        FirestoreOperationCounter.instance.recordRead(
          isFromCache: snapshot.metadata.isFromCache,
        );
      }
      if (!snapshot.exists) {
        logger.warning('$D not found(id: ${ref.documentID})');
        return null;
      }
      return collectionRef.decoder(snapshot);
    });
  }

  Future<D> get({Transaction transaction}) async {
    final snapshot =
        await (transaction == null ? ref.get() : transaction.get(ref));
    if (recordFirestoreOperationCount) {
      FirestoreOperationCounter.instance.recordRead(
        isFromCache: snapshot.metadata.isFromCache,
      );
    }
    if (!snapshot.exists) {
      logger.warning('$D not found(id: ${ref.documentID})');
      return Future.value(null);
    }
    return collectionRef.decoder(snapshot);
  }

  /// すでにあるデータに対して
  /// マージと似ているがそのキーの配下のものは置き換わる
  Future<void> update(
    E entity, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    return updateData(
      collectionRef.encoder(entity),
      batch: batch,
      transaction: transaction,
    );
  }

  /// すでにあるデータに対して
  /// マージと似ているがそのキーの配下のものは置き換わる
  Future<void> updateData(
    Map<String, dynamic> data, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    assert(batch == null || transaction == null);
    if (recordFirestoreOperationCount) {
      FirestoreOperationCounter.instance.recordWrite();
    }
    if (batch == null && transaction == null) {
      return ref.updateData(data);
    }
    if (batch != null) {
      batch.updateData(ref, data);
      return Future.value(null);
    }
    if (transaction != null) {
      transaction.update(ref, data);
      return Future.value(null);
    }
    assert(false);
    return Future.value(null);
  }

  /// 全置き換え
  Future<void> set(
    E entity, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    return setData(
      collectionRef.encoder(entity),
      batch: batch,
      transaction: transaction,
    );
  }

  /// 全置き換え
  Future<void> setData(
    Map<String, dynamic> data, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    assert(batch == null || transaction == null);
    if (recordFirestoreOperationCount) {
      FirestoreOperationCounter.instance.recordWrite();
    }
    if (batch == null && transaction == null) {
      return ref.setData(data);
    }
    if (batch != null) {
      batch.setData(ref, data);
      return Future.value(null);
    }
    if (transaction != null) {
      transaction.set(ref, data);
      return Future.value(null);
    }
    assert(false);
    return Future.value(null);
  }

  /// マージ
  Future<void> merge(
    E entity, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    return mergeData(
      collectionRef.encoder(entity),
      batch: batch,
      transaction: transaction,
    );
  }

  /// マージ
  Future<void> mergeData(
    Map<String, dynamic> data, {
    WriteBatch batch,
    Transaction transaction,
  }) {
    assert(batch == null || transaction == null);
    if (recordFirestoreOperationCount) {
      FirestoreOperationCounter.instance.recordWrite();
    }
    if (batch == null && transaction == null) {
      return ref.setData(data, merge: true);
    }
    if (batch != null) {
      batch.setData(ref, data, merge: true);
      return Future.value(null);
    }
    if (transaction != null) {
      throw UnsupportedError(
        'Unsupported currently: '
        'https://github.com/FirebaseExtended/flutterfire/issues/1212',
      );
//      transaction.set(ref, data, merge: true);
//      return Future.value(null);
    }
    assert(false);
    return Future.value(null);
  }

  Future<void> delete({
    WriteBatch batch,
    Transaction transaction,
  }) {
    assert(batch == null || transaction == null);
    if (recordFirestoreOperationCount) {
      FirestoreOperationCounter.instance.recordDelete();
    }
    if (batch == null && transaction == null) {
      return ref.delete();
    }
    if (batch != null) {
      batch.delete(ref);
      return Future.value(null);
    }
    if (transaction != null) {
      transaction.delete(ref);
      return Future.value(null);
    }
    assert(false);
    return Future.value(null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentRef &&
          runtimeType == other.runtimeType &&
          ref == other.ref;

  @override
  int get hashCode => ref.hashCode;
}
