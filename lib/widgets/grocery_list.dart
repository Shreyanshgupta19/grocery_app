import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget{
  const GroceryList({super.key,});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  String? _error;

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-18e97-default-rtdb.firebaseio.com', 'grocery_app.json');
    try {
      final response = await http.get(url);
      // print(response);    // output:-   Instance of 'Response'
      // print(response.body);  // output:-   {"-NmCn3RrZiQDL35l7Haa":{"category":"Vegetables","name":"ss","quantity":1},
      // final Map<String, Map<String, dynamic>> listData = json.decode(response.body);  // output:-   Error: Expected a value of type 'Map<String, Map<String, dynamic>>', but got one of type '_JsonMap'


      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }
      // print(response.body);
      if (response.body == 'null') { // we don't write null because firebase returns to string null So we write String with the text null inside it
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      // print(listData); // output:-  {"-NmCn3RrZiQDL35l7Haa": {"category": "Vegetables", "name": "ss", "quantity": 1},
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((catItem) =>
        catItem.value.title == item.value['category'])
            .value; // Category('Vegetables', Color.fromARGB(255, 0, 255, 128),),
        loadedItems.add(GroceryItem(id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,));
      }
      setState(() {
        _groceryItems = loadedItems; // e.g., GroceryItem(id:"-NmCn3RrZiQDL35l7Haa", name: "ss", quantity: 1, category: Category('Vegetables', Color.fromARGB(255, 0, 255, 128),), )
       // _isLoading = false;
      });
    }
    // throw Exception('An error occurred!');
    catch (err) {
      // print(err);
      setState(() {
        _error = 'Something went wrong!. Please try again later.';
        _isLoading = false;
      });
    }

  }

    void _addItem() async {
      final newItem = await Navigator.of(context).push<GroceryItem>(
          MaterialPageRoute(builder: (ctx) => const NewItem(),));

      if (newItem == null) {
        return;
      }
      else {
        setState(() {
          _groceryItems.add(newItem);
        });
      }
      //  _loadItems();
      // final newItem = await Navigator.of(context).push<GroceryItem>( MaterialPageRoute( builder: (ctx) => const NewItem(), ) );
      // if(newItem == null) {
      //   return;
      // }
      // else{
      //   setState(() {
      //     _groceryItems.add(newItem);
      //   });
      // }

    }

    void _removeItem(GroceryItem item) async {
      final index = _groceryItems.indexOf(item);
      setState(() {
        _groceryItems.remove(item);
      });
      final url = Uri.https('flutter-prep-18e97-default-rtdb.firebaseio.com',
          'grocery_app/${item.id}.json');
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        // Optional: Show error message
        setState(() {
          _groceryItems.insert(index, item);
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      Widget content = const Center(child: Text('No items added yet.'),);

      if (_isLoading) { // _isLoading = true
        content = const Center(child: CircularProgressIndicator());
      }

      if (_groceryItems.isNotEmpty) {
        content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) =>
              Dismissible(
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]); // catch the item at index
                },
                key: ValueKey(_groceryItems[index].id), // Uniqueness
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category
                        .color, // here groceryItems[index] is just like a key
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ),

        );
      }

      if (_error != null) {
        content = Center(child: Text(_error!),);
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: content,
      );
    }


}