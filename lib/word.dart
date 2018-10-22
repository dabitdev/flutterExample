import 'package:sqflite/sqflite.dart';

final String tableWord = "word";
final String columnId = "_id";
final String columnWord = "original_word";
final String columnDone = "done";
final String columnTranslatedWord = "translated_word";

class Word {
  int id;
  String originalWord;
  String translatedWord;
  bool done;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWord: originalWord,
      columnTranslatedWord: translatedWord,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Word();

  Word.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    originalWord = map[columnWord];
    translatedWord = map[columnTranslatedWord];
    done = map[columnDone] == 1;
  }
}

class WordProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
              create table $tableWord ( 
                $columnId integer primary key autoincrement, 
                $columnWord text not null,
                $columnTranslatedWord text not null,
                $columnDone integer not null)
              ''');
        });
  }

  Future<Word> insert(Word word) async {
    word.id = await db.insert(tableWord, word.toMap());
    return word;
  }

  Future<Word> getWord(int id) async {
    List<Map> maps = await db.query(tableWord,
        columns: [columnId, columnDone, columnWord],
        where: "$columnId = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new Word.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableWord, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> update(Word word) async {
    return await db.update(tableWord, word.toMap(),
        where: "$columnId = ?", whereArgs: [word.id]);
  }

  Future close() async => db.close();
}