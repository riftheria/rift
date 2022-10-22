// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_persistent_sql_word_dao.dart';

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$LocalPersistentWordDaoMixin on DatabaseAccessor<RiftDatabase> {
  $WordsTable get words => attachedDatabase.words;
  $DefinitionsTable get definitions => attachedDatabase.definitions;
  $MeaningsTable get meanings => attachedDatabase.meanings;
  Selectable<int> wordCount() {
    return customSelect('SELECT COUNT(*) FROM words',
        variables: [],
        readsFrom: {
          words,
        }).map((QueryRow row) => row.read<int>('COUNT(*)'));
  }
}
