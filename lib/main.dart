import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import './bloc_favorite_page.dart';
import './models/word_item.dart';
import './word_bloc.dart';
import './word_provider.dart';
import './models/suggestion.dart';
import './widgets/count_label.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WordProvider(
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: new ThemeData(primaryColor: Colors.white),
        home: RandomWordsHomePage(),
        routes: <String, WidgetBuilder> {
          // 「./favorite」に、BlocFavoritePageを登録
          BlocFavoritePage.routeName: (context) => BlocFavoritePage()
        },
      ),
    );
  }
}

class RandomWordsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wordBloc = WordProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Startup Name Generator"),
        actions: <Widget>[

          //いいねの数を表示している
          StreamBuilder<int>(
              stream: wordBloc.itemCount,
              initialData: 0,
              builder: (context, snapshot) => CountLabel(
                favoriteCount: snapshot.data,
              )
          ),
          new IconButton(
              icon: const Icon(Icons.list),
              onPressed: (){

                //いいねリストに画面遷移
                Navigator.of(context).pushNamed(BlocFavoritePage.routeName);
              }
          )
        ],
      ),
      body: WordList(),
    );
  }
}
class WordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),

        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();

          final index = i ~/ 2;
          if (index >= suggestion.suggestionCount) {
            const addNum = 10;
            suggestion.addMulti(generateWordPairs().take(addNum).toList());
          }
          return _buildRow(WordProvider.of(context), suggestion.suggestedWords[index]);
        }
    );
  }
}

// Favorite済み、すなわちword.itemsに含まれていれば、赤いハートアイコンにする
Widget _buildRow(WordBloc word, WordPair pair) {
  return new StreamBuilder<List<WordItem>>(
      stream: word.items,
      builder: (_, snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return _createWordListTile(word, false, pair.asPascalCase);
        } else {
          final addedWord = snapshot.data.map(
                  (item) {
                return item.name;
              }
          );
          final alreadyAdded = addedWord.toString().contains(pair.asPascalCase);
          return _createWordListTile(word, alreadyAdded, pair.asPascalCase);
        }
      }
  );
}

ListTile _createWordListTile(WordBloc word, bool isFavorited, String title) {
  return new ListTile(
    title: new Text(title),
    trailing: new Icon(
      isFavorited ? Icons.favorite : Icons.favorite_border,
      color: isFavorited ? Colors.red : null,
    ),
    onTap: () {
      if (isFavorited) {
        word.wordRemoval.add(WordRemoval(title));
      } else {
        word.wordAddition.add(WordAddition(title));
      }
    },
  );
}
