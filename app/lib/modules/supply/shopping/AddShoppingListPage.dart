import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../SupplyModels.dart';
import '../SupplyRepository.dart';
import 'ArticleEntryDialog.dart';
import 'RecipeDialog.dart';

class AddShoppingListPage extends StatefulWidget {
  @override
  _AddShoppingListPageState createState() => _AddShoppingListPageState();
}

class _AddShoppingListPageState extends State<AddShoppingListPage> {
  String listName = "";
  ArticleEntry currentEntry;
  List<ArticleEntry> listEntries = [];

  TextEditingController articleController;

  @override
  void initState() {
    super.initState();
    articleController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Speichern",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await Provider.of<SupplyRepository>(context, listen: false).saveShoppingList(listName, listEntries);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Titel',
              ),
              onChanged: (String name) {
                listName = name;
              },
            ),
            Container(height: 20),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Suche nach Artikeln oder Rezepten',
              )),
              suggestionsCallback: (pattern) async {
                SupplyRepository repository = Provider.of<SupplyRepository>(context, listen: false);
                List<dynamic> suggestions = [];
                suggestions.addAll(
                  repository.articles.where((article) => article.name.toLowerCase().contains(pattern.toLowerCase())).toList(),
                );
                suggestions.addAll(
                  repository.articleLists
                      .whereType<Recipe>()
                      .where((recipe) => recipe.name.toLowerCase().contains(pattern.toLowerCase()))
                      .toList(),
                );
                return suggestions;
              },
              itemBuilder: (context, dynamic suggestion) {
                return ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text(suggestion.name),
                );
              },
              onSuggestionSelected: (suggestion) async {
                if (suggestion is Article) {
                  ArticleEntry articleEntry = await ArticleEntryDialog.open(context, suggestion);
                  if (articleEntry != null) {
                    setState(() {
                      listEntries.add(articleEntry);
                    });
                  }
                } else if (suggestion is Recipe) {
                  List<ArticleEntry> articleEntries = await RecipeDialog.open(context, suggestion);
                  if (articleEntries != null) {
                    setState(() {
                      listEntries.addAll(articleEntries);
                    });
                  }
                }
                articleController.text = "";
              },
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: listEntries.length,
                  itemBuilder: (context, index) {
                    return Selector<SupplyRepository, Article>(
                      selector: (context, repo) => repo.getArticleById(listEntries[index].articleId),
                      builder: (BuildContext context, Article article, _) {
                        return ListTile(
                          title: Text(article.name),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
