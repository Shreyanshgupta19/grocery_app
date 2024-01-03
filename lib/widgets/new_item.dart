import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/categories.dart';
import 'package:grocery_app/models/category.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;  // as keyword here is an important keyword and it tells dart that all the content that's provided by this package should be bundled into http, but this could be any name of our choice

class NewItem extends StatefulWidget{
  const NewItem({super.key,});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if( _formKey.currentState!.validate() ) {
    _formKey.currentState!.save();
    setState(() {
      _isSending = true;
    });
    final url = Uri.https('flutter-prep-18e97-default-rtdb.firebaseio.com', 'grocery_app.json');
    final response = await http.post(   // post : Future<Response> post( Uri url, { Map<String, String>? headers, Object? body, Encoding? encoding, } );
        url,
        headers: { 'Content-Type' : 'application/json' },
        body: json.encode({
      'name': _enteredName,
      'quantity': _enteredQuantity,
      'category': _selectedCategory.title,
        })
    );

    final Map<String, dynamic> resData = json.decode(response.body);
    // print(resData);               // output:- {'name': '-NmKGmqWgX4R3S1i8qHz'}
    // print(response.body);         // output:- {"name":"-NmKGmqWgX4R3S1i8qHz"}
    // print(response.statusCode);
    if(!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    Navigator.of(context).pop(GroceryItem(id: resData['name'], name: _enteredName, quantity: _enteredQuantity, category: _selectedCategory,),);
   // Navigator.of(context).pop( GroceryItem(id: DateTime.now().toString(), name: _enteredName, quantity: _enteredQuantity, category: _selectedCategory) );
    // print(_enteredName);
    // print(_enteredQuantity);
    // print(_selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty || value.trim().length <= 1 || value.trim().length > 50){
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // if(value == null){
                    //   return;
                    // }
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredQuantity.toString(),
                        validator: (value){
                          if(value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0){
                            return 'Must be a valid, positive number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                        for (final category in categories.entries)  // categories.entries : in categories.dart file,if you take a look at categories class, it is actually a map, not a list and we can't loop through a map like this So Thankfully,it's quite easy to convert it to a list though by using the special entries property that is available on all Dart maps, So this is a property provided by Dart on every map and entries gives you an iterable which in the end contains all your map key value pairs as items in that iterable so in that list in the end So here we can loop through all our category entries then and we get these entry item objects then.
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6,),
                                Text(category.value.title),
                              ],
                            ),
                          )

                      ],
                        onChanged: (value){
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   TextButton(
                     onPressed: _isSending  // (false) // In flutter, a button can be disabled  by simply passing 'null' to onPressed instead of a function // null means button does not do any thing
                         ? null   // when _isSending is true this is button is disabled
                         : (){   // (false)
                     _formKey.currentState!.reset();
                   },
                     child: const Text('Reset'),),
                   ElevatedButton(
                     onPressed: _isSending? null: _saveItem,
                     child: _isSending? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(),) : const Text('Add Item'),
                   ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );
  }
}
// n Flutter, the onPressed property of a button expects a function that will be executed when the button is pressed. By setting onPressed to null, you are effectively disabling the button, meaning it won't respond to user interactions.
// The use of null in this context is a way to conditionally disable the buttons when _isSending is true. This prevents users from clicking the buttons while a network request (possibly _saveItem function) is in progress (_isSending is true). This is a common practice to provide better user experience and prevent unwanted user interactions that could interfere with ongoing operations.
