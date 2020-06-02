import 'package:disposable_provider/disposable_provider.dart';
import 'package:firestore_ref/firestore_ref.dart';
import 'package:firestore_ref/src/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

import 'document_list.dart';

class CollectionPagingController<E, D extends Document<E>> with Disposable {
  CollectionPagingController({
    @required
        Stream<QuerySnapshot> Function(QueryBuilder queryBuilder)
            snapshotBuilder,
    @required DocumentDecoder<D> decoder,
    QueryBuilder queryBuilder,
    int initialSize = 10,
    this.defaultPagingSize = 10,
  }) {
    _limitController.stream.switchMap((limit) {
      final documentList = DocumentList<E, D>(decoder: (snapshot) {
        final cached = _documentsCache[snapshot.reference];
        if (cached != null && snapshot.metadata.isFromCache) {
          logger.fine('cache hit (id: ${cached.id})');
          return cached;
        }
        final doc = decoder(snapshot);
        _documentsCache[snapshot.reference] = doc;
        return doc;
      });
      return snapshotBuilder(
        (query) => (queryBuilder ?? (q) => q)(query).limit(limit),
      ).map(documentList.applyingSnapshot);
    }).pipe(_documentsController);

    _documentsController
        .map((documents) => documents.length >= _limitController.value)
        .pipe(_hasMoreController);

    _limitController.add(initialSize);
  }

  final int defaultPagingSize;

  final _documentsController = BehaviorSubject<List<D>>.seeded([]);
  final _limitController = BehaviorSubject<int>();
  final _hasMoreController = BehaviorSubject<bool>.seeded(true);
  final _documentsCache = <DocumentReference, D>{};

  ValueStream<List<D>> get documents => _documentsController.stream;
  ValueStream<bool> get hasMore => _hasMoreController.stream;

  bool loadMore({int pagingSize}) {
    if (!hasMore.value) {
      return false;
    }
    _limitController.add(
      _limitController.value + (pagingSize ?? defaultPagingSize),
    );
    return true;
  }

  @override
  Future<void> dispose() async {
    await _limitController.close();
    await _documentsController.drain<void>();
    await _documentsController.close();
    await _hasMoreController.close();
  }
}
